// ============================================
// MÉTODOS CRUD PARA CARRERAS
// Agregar estos métodos al final de la clase AdminService en admin.service.ts
// ============================================

/**
 * Get all carreras
 */
async getCarreras() {
    const { data, error } = await this.supabaseService
        .getClient()
        .from('carreras')
        .select('*')
        .order('nombre', { ascending: true });

    if (error) {
        this.logger.error(`Error fetching carreras: ${error.message}`);
        throw new InternalServerErrorException('Error al obtener carreras');
    }

    return data;
}

/**
 * Create a new carrera
 */
async createCarrera(dto: CreateCarreraDto) {
    const { data, error } = await this.supabaseService
        .getClient()
        .from('carreras')
        .insert({
            nombre: dto.nombre,
            codigo: dto.codigo,
            activa: dto.activa ?? true,
        })
        .select()
        .single();

    if (error) {
        this.logger.error(`Error creating carrera: ${error.message}`);
        if (error.code === '23505') {
            throw new BadRequestException('Ya existe una carrera con ese nombre o código');
        }
        throw new InternalServerErrorException('Error al crear carrera');
    }

    this.logger.log(`Carrera created: ${data.nombre}`);
    return data;
}

/**
 * Update a carrera
 */
async updateCarrera(id: string, dto: UpdateCarreraDto) {
    const { data, error } = await this.supabaseService
        .getClient()
        .from('carreras')
        .update(dto)
        .eq('id', id)
        .select()
        .single();

    if (error) {
        this.logger.error(`Error updating carrera: ${error.message}`);
        if (error.code === '23505') {
            throw new BadRequestException('Ya existe una carrera con ese nombre o código');
        }
        throw new InternalServerErrorException('Error al actualizar carrera');
    }

    if (!data) {
        throw new NotFoundException('Carrera no encontrada');
    }

    this.logger.log(`Carrera updated: ${id}`);
    return data;
}

/**
 * Toggle carrera activa status
 */
async toggleCarrera(id: string) {
    // Get current status
    const { data: current } = await this.supabaseService
        .getClient()
        .from('carreras')
        .select('activa')
        .eq('id', id)
        .single();

    if (!current) {
        throw new NotFoundException('Carrera no encontrada');
    }

    // Toggle status
    const { data, error } = await this.supabaseService
        .getClient()
        .from('carreras')
        .update({ activa: !current.activa })
        .eq('id', id)
        .select()
        .single();

    if (error) {
        this.logger.error(`Error toggling carrera: ${error.message}`);
        throw new InternalServerErrorException('Error al cambiar estado de carrera');
    }

    this.logger.log(`Carrera toggled: ${id} -> ${!current.activa}`);
    return data;
}

// ============================================
// MÉTODOS CRUD PARA GRADOS ACADÉMICOS
// ============================================

/**
 * Get all grados académicos
 */
async getGradosAcademicos() {
    const { data, error } = await this.supabaseService
        .getClient()
        .from('grados_academicos')
        .select('*')
        .order('nivel', { ascending: true });

    if (error) {
        this.logger.error(`Error fetching grados académicos: ${error.message}`);
        throw new InternalServerErrorException('Error al obtener grados académicos');
    }

    return data;
}

/**
 * Create a new grado académico
 */
async createGradoAcademico(dto: CreateGradoAcademicoDto) {
    const { data, error } = await this.supabaseService
        .getClient()
        .from('grados_academicos')
        .insert({
            nombre: dto.nombre,
            codigo: dto.codigo,
            nivel: dto.nivel,
            activo: dto.activo ?? true,
        })
        .select()
        .single();

    if (error) {
        this.logger.error(`Error creating grado académico: ${error.message}`);
        if (error.code === '23505') {
            throw new BadRequestException('Ya existe un grado académico con ese nombre o código');
        }
        throw new InternalServerErrorException('Error al crear grado académico');
    }

    this.logger.log(`Grado académico created: ${data.nombre}`);
    return data;
}

/**
 * Update a grado académico
 */
async updateGradoAcademico(id: string, dto: UpdateGradoAcademicoDto) {
    const { data, error } = await this.supabaseService
        .getClient()
        .from('grados_academicos')
        .update(dto)
        .eq('id', id)
        .select()
        .single();

    if (error) {
        this.logger.error(`Error updating grado académico: ${error.message}`);
        if (error.code === '23505') {
            throw new BadRequestException('Ya existe un grado académico con ese nombre o código');
        }
        throw new InternalServerErrorException('Error al actualizar grado académico');
    }

    if (!data) {
        throw new NotFoundException('Grado académico no encontrado');
    }

    this.logger.log(`Grado académico updated: ${id}`);
    return data;
}

/**
 * Toggle grado académico activo status
 */
async toggleGradoAcademico(id: string) {
    // Get current status
    const { data: current } = await this.supabaseService
        .getClient()
        .from('grados_academicos')
        .select('activo')
        .eq('id', id)
        .single();

    if (!current) {
        throw new NotFoundException('Grado académico no encontrado');
    }

    // Toggle status
    const { data, error } = await this.supabaseService
        .getClient()
        .from('grados_academicos')
        .update({ activo: !current.activo })
        .eq('id', id)
        .select()
        .single();

    if (error) {
        this.logger.error(`Error toggling grado académico: ${error.message}`);
        throw new InternalServerErrorException('Error al cambiar estado de grado académico');
    }

    this.logger.log(`Grado académico toggled: ${id} -> ${!current.activo}`);
    return data;
}
