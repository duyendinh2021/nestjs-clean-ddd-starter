export abstract class BaseEntity {
  protected constructor(
    public readonly id: string,
    public readonly createdAt: Date = new Date(),
    public readonly updatedAt: Date = new Date(),
  ) {}

  public equals(entity: BaseEntity): boolean {
    return this.id === entity.id;
  }
}
