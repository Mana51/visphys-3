 document.getElementById("drawButton").addEventListener("click", function () {
    fabricCanvas.isDrawingMode = true;
    fabricCanvas.freeDrawingBrush.width = 5;
    fabricCanvas.freeDrawingBrush.color = "black";
  });
  
  document.getElementById("selectButton").addEventListener("click", function () {
    fabricCanvas.isDrawingMode = false;
  });
  
  document.getElementById("clearButton").addEventListener("click", function () {
    fabricCanvas.clear();
  });
  
  document.getElementById("downloadButton").addEventListener("click", function () {
    const combinedCanvas = document.createElement('canvas');
    combinedCanvas.width = fabricCanvas.width;
    combinedCanvas.height = fabricCanvas.height;
  
    const combinedContext = combinedCanvas.getContext('2d');
    const matterContext = matterCanvas.getContext('2d');
  
    combinedContext.drawImage(matterCanvas, 0, 0);
  
    fabricCanvas.renderAll();
    const fabricImage = fabricCanvas.toCanvasElement();
    combinedContext.drawImage(fabricImage, 0, 0);
  
    const link = document.createElement('a');
    link.href = combinedCanvas.toDataURL('image/png');
    link.download = 'visphys.png';
    link.click();
  });