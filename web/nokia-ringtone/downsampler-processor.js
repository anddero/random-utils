// downsampler-processor.js
class DownsamplerProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    this.recBuffers = [];
    this.recLength = 0;
    
    // Listen for messages from the main thread
    this.port.onmessage = (event) => {
      if (event.data.message === 'complete') {
        // Send the collected buffers back when processing is complete
        this.port.postMessage({
          message: 'buffers',
          recBuffers: this.recBuffers,
          recLength: this.recLength
        });
      }
    };
  }

  process(inputs, outputs) {
    // Get input data (we expect mono or will convert to mono)
    const inputChannels = inputs[0];
    if (inputChannels.length === 0) return true;
    
    // Convert to mono if needed by averaging all channels
    const monoData = new Float32Array(inputChannels[0].length);
    
    for (let i = 0; i < monoData.length; i++) {
      let sum = 0;
      for (let channel = 0; channel < inputChannels.length; channel++) {
        sum += inputChannels[channel][i];
      }
      monoData[i] = sum / inputChannels.length;
    }
    
    // Store the mono data
    this.recBuffers.push(new Float32Array(monoData));
    this.recLength += monoData.length;
    
    // Keep the processor alive
    return true;
  }
}

registerProcessor('downsampler-processor', DownsamplerProcessor);
