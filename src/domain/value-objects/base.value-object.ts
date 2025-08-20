export abstract class ValueObject<T> {
  protected constructor(public readonly props: T) {}

  public equals(valueObject: ValueObject<T>): boolean {
    return JSON.stringify(this.props) === JSON.stringify(valueObject.props);
  }
}
