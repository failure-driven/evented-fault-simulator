export interface MessageData {
  traceId: string; // UUID
  name: string;
  event: string; // processStarted, processStopped, etc
  timeUnixNano: number;
  attributes: Array<{ key: string, value: any }>;
}
