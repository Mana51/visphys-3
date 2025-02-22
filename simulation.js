let ballY = 0;
let ballYSpeed = 0;
let buildingHeight = 19.6;
let secsForDrop = 2.0;
let g = 9.8; 

function setup() {
  createCanvas(600, 900);
}

function draw() {
  background(200);

  let timeElapsed = map(mouseX, 0, width, 0.0, secsForDrop);
  ballY = buildingHeight - 0.5 * g * Math.pow(timeElapsed, 2); 
  ballYSpeed = g * timeElapsed;

  let ballX = width / 2;
  let drawY = map(ballY, 0, buildingHeight, height, 0);

  fill(255, 0, 0);
  ellipse(ballX, drawY, 50, 50);

  fill(0, 0, 0);
  text(`Time: ${timeElapsed.toFixed(2)} s`, width - 100, 50);
  text(`Ball Y: ${ballY.toFixed(2)} m`, width - 100, 70);
  text(`Ball Speed: ${ballYSpeed.toFixed(2)} m/s`, width - 100, 90);

  for (let y = 0; y <= buildingHeight; y += 5) {
    let drawY = map(y, 0, buildingHeight, height, 0);
    line(50, drawY, width, drawY);
  }

  for (let x = 0; x <= secsForDrop; x += 0.5) {
    let drawX = map(x, 0.0, secsForDrop, 0, width);
    line(drawX, 0, drawX, height);
  }
}
