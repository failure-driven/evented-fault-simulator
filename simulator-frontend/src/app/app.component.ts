import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { TelemetryDataService } from './telemetry-data.service';
import { NgFor } from '@angular/common';
import { MessageData } from './message-data';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, NgFor],
  template: `
    <h1>Welcome to {{title}}!</h1>
    <ul *ngFor="let process of processes">
      <li>
        {{ process.name }}<br/>
        {{ process.traceId }}<br/>
        {{ process.pid }}
      </li>
    </ul>
    <code *ngFor="let datum of dataString">
     {{ datum }}
      <br/>
    </code>
    <router-outlet />
  `,
  styles: [],
})
export class AppComponent {
  title = 'simulator-frontend';
  data: MessageData[] = [];
  dataString: String[] = [];
  processes: any[] = [];

  constructor(private telemetryDataService: TelemetryDataService) {
    this.telemetryDataService.createEventSource().subscribe((message: MessageData) => {
      // console.log(message)
      this.setData(message)
    })
  }

  setData = (message: MessageData) => {
    if(message.event === 'processStarted') {
      const pid = message.attributes.filter((attr) => attr.key === "pid")[0]?.value?.value;
      this.processes.push({...message, pid});
    }
    if(message.event === 'processStopped') {
      this.processes = this.processes.filter((process) => process.traceId !== message.traceId);
    }
    this.data.length > 10 ? this.data.pop() : null;
    this.data.unshift(message);

    this.dataString.length > 10 ? this.dataString.pop() : null;
    const {event , traceId, timeUnixNano} = message;
    this.dataString.unshift(JSON.stringify({event, traceId, timeUnixNano}));
  };
}
