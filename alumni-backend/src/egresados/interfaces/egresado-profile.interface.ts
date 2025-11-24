export interface IEgresadoProfile {
  id: string;
  uid: string;
  correo: string;
  nombre: string;
  apellido: string;
  carrera_id?: string;
  telefono?: string;
  ciudad?: string;
  estado_laboral_id?: string;
  empresa_actual?: string;
  cargo_actual?: string;
}
