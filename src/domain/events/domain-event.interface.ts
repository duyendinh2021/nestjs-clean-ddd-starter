export interface DomainEvent {
  readonly aggregateId: string;
  readonly occurredOn: Date;
  readonly eventType: string;
}
