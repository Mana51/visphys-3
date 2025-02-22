require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'
require 'openai'
require 'json'
require 'dotenv'
require 'dotenv/load'
require 'net/http'
require 'cloudinary'
require 'sinatra/flash'
require 'securerandom'
require 'json'
require 'faye/websocket'

#WebSocket接続を格納する
set :sockets, []
clients = []

# チャンネルごとのWebSocket接続を管理するハッシュ
channels = Hash.new { |hash, key| hash[key] = [] }

# トークンごとに異なるWebSocket接続を確立
get '/ws/:token' do
  if Faye::WebSocket.websocket?(env)
    token = params[:token]
    ws = Faye::WebSocket.new(env)

    ws.on :open do |event|
      puts "WebSocket connection opened for token: #{token}"
      channels[token] << ws
      
      # 定期的にpingメッセージを送信して接続を維持
      # pingはサーバーが定期的に送信し、クライアントが応答することで接続を維持する
      # @ping_interval = EM.add_periodic_timer(30) do
      #   if ws.open?
      #     ws.ping("ping")  # pingメッセージを送信
      #   else
      #     @ping_interval.cancel  # 接続が閉じていればpingタイマーを停止
      #   end
      # end
    end

    ws.on :message do |event|
      puts "Message received on token #{token}: #{event.data}"
      channels[token].each { |client| client.send(event.data) }
    end

    ws.on :close do |event|
      puts "WebSocket connection closed for token: #{token}"
      channels[token].delete(ws)
      ws = nil
      channels.delete(token) if channels[token].empty?
      # pingタイマーを停止
      # @ping_interval.cancel if @ping_interval
    end

    ws.rack_response
  else
    status 400
  end
end


enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before do
  protected_routes = ['/home', '/free_fall', '/tousoku_tyokusen', '/toukasoku', '/syahou', '/masatu', '/tension', '/slope', '/spring_slope', '/hanpatu', '/syoutotu_1d', '/circle', '/tansindou']
  
  # If the user tries to access a protected route and is not logged in, save the path and redirect to the login page
  if !current_user && protected_routes.include?(request.path_info)
    session[:redirect_to] = request.path_info
    redirect '/signin'
  end
end

get '/' do
  erb :sign_in
end

get '/signin' do
  erb :sign_in
end

post '/signin' do
 user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
    if session[:redirect_to]
      redirect session[:redirect_to]
    else
      redirect '/home'
    end
  else
    flash[:error] = ' ログイン情報に間違いがあります'
    redirect '/signin' 
  end
end

get '/signup' do
  erb :sign_up
end

post '/signup' do
    # ユーザーネームがすでに存在するか確認
    existing_user = User.find_by(name: params[:name])

    if existing_user
      # すでに存在するユーザーネームの場合はエラーメッセージを表示
      flash[:error] = ' すでにユーザーネームが存在します'
      redirect '/signup'
    else
      # ユーザーを新規作成
      user = User.create(
          name: params[:name],
          password: params[:password],
          password_confirmation: params[:password_confirmation]
      )

      if user.persisted?
        session[:user] = user.id
        if session[:redirect_to]
          redirect session[:redirect_to]
        else
          redirect '/home'
        end
      else 
        flash[:error] = ' パスワードが正しくありません'
        redirect '/signup'
      end
    end
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end

get '/home' do
  erb :home
end


get '/theme' do
  query = params[:query]
  erb query.to_sym
end



post '/saveSimulation' do
  # データを保存する処理
  simulation = SavedSimulation.create(
    user_id: session[:user],
    title: params[:title],
    simulation_type: params[:simulation_type],
    variables: params[:variables].to_json
  )
  
  if simulation.persisted?
    redirect '/mypage'
  else
    # 保存に失敗した場合の処理
    flash[:error] = "シミュレーションの保存に失敗しました"
    redirect back
  end
end

get '/custom' do
  @saved_simulations = SavedSimulation.all.sort.reverse
  erb :custom
end

get '/mypage' do
  @saved_simulations = SavedSimulation.where(user_id: session[:user]).sort.reverse
  erb :mypage
end


get '/load_simulation/:id' do
  @simulation = SavedSimulation.find(params[:id])
  
  # @variablesの設定
  @variables = @simulation.variables ? JSON.parse(@simulation.variables) : {}

  puts "Loaded variables: #{@variables.inspect}"  # Debug statement

  erb :"#{@simulation.simulation_type}"
end


post '/custom/search' do
  search_term = params[:search]
  @search_results = SavedSimulation.where("title LIKE ?", "%#{search_term}%").sort.reverse
  erb :search
end

post '/mypage/search' do
  search_term = params[:search]
  @search_results =  SavedSimulation.where(user_id: session[:user]).where("title LIKE ?", "%#{search_term}%").sort.reverse
  erb :search
end

post '/mypage/filter' do
  selected_simulations = params[:simulations]
  if selected_simulations
    @saved_simulations = SavedSimulation.where(simulation_type: selected_simulations, user_id: session[:user]).sort.reverse
    erb :mypage
  else
    redirect '/mypage'
  end
end

post '/custom/filter' do
  selected_simulations = params[:simulations]
  if selected_simulations
    @saved_simulations = SavedSimulation.where(simulation_type: selected_simulations).sort.reverse
    erb :custom
  else
    redirect '/custom'
  end
end

post '/shareSimulation' do
  # ランダムなトークンを生成
  token = SecureRandom.hex(10) # 10バイトのランダムな文字列

  shared_simulation = SharedSimulation.create(
    title: params[:title],
    simulation_type: params[:simulation_type],
    variables: params[:variables].to_json,
    user_id: session[:user],
    token: token
  )
  
  base_url = request.base_url
  
  link = "#{base_url}/share/#{shared_simulation.token}"
  { share_link: link }.to_json

end


get '/share/:token' do
  # トークンを使ってシェアされたシミュレーションを取得
  shared_simulation = SharedSimulation.find_by(token: params[:token])
  @token = params[:token]

  if shared_simulation.nil?
    # シミュレーションが見つからない場合のエラーハンドリング
    halt 404, "シミュレーションが見つかりません"
  end

  if session[:user].nil?
    # リンク受け取った人がログインしていない場合はログインへリダイレクト
    session[:redirect_to] = request.path
    redirect '/signin'
  else
    @variables = JSON.parse(shared_simulation.variables)
    erb :"#{shared_simulation.simulation_type}"
  end
end