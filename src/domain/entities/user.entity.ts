// Example Entity
export class User {
  constructor(
    public readonly id: string,
    public readonly email: string,
    public readonly name: string,
    public readonly createdAt: Date = new Date(),
  ) {}

  public updateName(newName: string): User {
    // Business logic here
    if (!newName || newName.trim().length === 0) {
      throw new Error('Name cannot be empty');
    }

    return new User(this.id, this.email, newName, this.createdAt);
  }

  public isValid(): boolean {
    return this.email.includes('@') && this.name.length > 0;
  }
}
