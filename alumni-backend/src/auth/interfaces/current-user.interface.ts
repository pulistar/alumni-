export interface ICurrentUser {
  id: string;
  email: string;
}

export interface ICurrentAdmin extends ICurrentUser {
  role: string;
  nombre?: string;
  apellido?: string;
}
