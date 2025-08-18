// Web camera permissions helper
window.requestCameraPermission = function() {
  return navigator.mediaDevices.getUserMedia({ video: true })
    .then(function(stream) {
      // Stop the stream immediately, we just wanted to check permissions
      stream.getTracks().forEach(track => track.stop());
      return true;
    })
    .catch(function(error) {
      console.error('Camera permission denied:', error);
      return false;
    });
};

// Check if camera is available
window.isCameraAvailable = function() {
  return !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia);
};