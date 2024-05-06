import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { MessageData } from './message-data';

@Injectable({
  providedIn: 'root'
})

export class TelemetryDataService {

  constructor() { }

  createEventSource(): Observable<MessageData> {
    // TODO: move out to env setup
    const eventSource = new EventSource("http://0.0.0.0:8080/");

    return new Observable(observer => {
      // NOTE: unnamed events
      eventSource.onmessage = (event) => {
        observer.next(event.data)
      };
      // NOTE: each named event
      eventSource.addEventListener("status", (event) => {
        const messageData: MessageData = JSON.parse(event.data);
        observer.next(messageData)
      });
    });

  }
}
