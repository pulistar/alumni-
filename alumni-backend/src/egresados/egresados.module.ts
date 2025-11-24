import { Module } from '@nestjs/common';
import { EgresadosService } from './egresados.service';
import { EgresadosController } from './egresados.controller';

@Module({
  controllers: [EgresadosController],
  providers: [EgresadosService],
  exports: [EgresadosService],
})
export class EgresadosModule {}
