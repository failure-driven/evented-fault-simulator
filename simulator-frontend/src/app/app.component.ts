import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { TelemetryDataService } from './telemetry-data.service';
import { NgFor } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, NgFor],
  template: `
    <h1>Welcome to {{title}}!</h1>
    <code *ngFor="let datum of data">
     {{ datum }}
      <br/>
    </code>
    <router-outlet />
  `,
  styles: [],
})
export class AppComponent {
  title = 'simulator-frontend';
  data: String[] = [];

  constructor(private telemetryDataService: TelemetryDataService) {
    this.telemetryDataService.createEventSource().subscribe((message: String) => {
      // console.log(message)
      this.setData(message)
    })
  }

  setData = (message: String) => {
    this.data.length > 10 ? this.data.shift() : null;
    this.data.push(message)};
}
