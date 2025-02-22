  // 使用モジュール
  const Engine = Matter.Engine,
    Render = Matter.Render,
    Runner = Matter.Runner,
    Body = Matter.Body,
    Bodies = Matter.Bodies,
    Composite = Matter.Composite,
    MouseConstraint = Matter.MouseConstraint,
    Mouse = Matter.Mouse;
    Events = Matter.Events;

  const engine = Engine.create();

  const matterCanvas = $('#matterCanvas')[0];
  const fabricCanvas = new fabric.Canvas('fabricCanvas');

  matterCanvas.width = 800;
  matterCanvas.height = 600;
  fabricCanvas.setWidth(800);
  fabricCanvas.setHeight(600);

  const render = Render.create({
    canvas: matterCanvas,
    engine: engine,
    options: {
      width: 800,
      height: 600,
      background: '#fafafa',
      wireframes: false
    }
  });

  const mouse = Mouse.create(render.canvas);
  const mouseConstraint = MouseConstraint.create(engine, {
    mouse: mouse,
    constraint: {
      render: { visible: false }
    }
  });

  Composite.add(engine.world, mouseConstraint);
  render.mouse = mouse;

  Render.run(render);
  const runner = Runner.create();
  Runner.run(runner, engine);

  const ground = Bodies.rectangle(400, 600, 800, 20, { isStatic: true });
  const leftWall = Bodies.rectangle(0, 300, 20, 600, { isStatic: true });
  const rightWall = Bodies.rectangle(800, 300, 20, 600, { isStatic: true });
  const roof = Bodies.rectangle(400, 0, 800, 20, { isStatic: true });
  Composite.add(engine.world, [ground, leftWall, rightWall, roof]);