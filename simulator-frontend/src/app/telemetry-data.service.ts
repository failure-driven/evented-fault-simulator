import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class TelemetryDataService {

  constructor() { }

  createEventSource(): Observable<String> {
    // TODO: move out to env setup
    const eventSource = new EventSource("http://0.0.0.0:9292/");

    return new Observable(observer => {
      // NOTE: unnamed events
      eventSource.onmessage = (event) => {
        // TODO: add json data and parsing would go here
        //       as well as MessageData type structure
        // const messageData: MessageData = JSON.parse(event.data);
        observer.next(event.data)
      };
      // NOTE: each named event
      eventSource.addEventListener("status", (event) => {
        observer.next(event.data)
      });
    });

  }
}
