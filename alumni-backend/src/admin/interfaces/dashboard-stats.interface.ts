export interface DashboardStats {
  total_egresados: number;
  egresados_habilitados: number;
  documentos_completos: number;
  autoevaluaciones_completas: number;
  por_carrera: CarreraStats[];
}

export interface CarreraStats {
  carrera: string;
  total: number;
  habilitados: number;
  documentos_completos: number;
  autoevaluaciones_completas: number;
  empleados: number;
  desempleados: number;
}
