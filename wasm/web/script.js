let ws_server = null;

class WebSocketServer {
  constructor() {
    this.listeners = {};
    ws_server = this;
  }

  on(event_name, callback) {
    if (this.listeners[event_name])
      this.listeners[event_name].push(callback);
    else
      this.listeners[event_name] = [callback];
  }

  close() {

  }
}