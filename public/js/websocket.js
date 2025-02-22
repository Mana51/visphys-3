const ws = new WebSocket('wss://' + window.location.host + '/ws'); //サーバーのWebSocketエンドポイント

document.addEventListener("DOMContentLoaded", function () {
    let isWsConnected = false;
    
    ws.onopen = () => {
        console.log('WebSocket connection established');
        isWsConnected = true;
    };
})