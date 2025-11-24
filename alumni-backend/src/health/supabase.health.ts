import { Injectable } from '@nestjs/common';
import { HealthIndicator, HealthIndicatorResult, HealthCheckError } from '@nestjs/terminus';
import { SupabaseService } from '../database/supabase.service';

@Injectable()
export class SupabaseHealthIndicator extends HealthIndicator {
  constructor(private readonly supabaseService: SupabaseService) {
    super();
  }

  async isHealthy(key: string): Promise<HealthIndicatorResult> {
    try {
      // Simple query to check database connectivity
      const { error } = await this.supabaseService
        .getClient()
        .from('carreras')
        .select('count')
        .limit(1);

      const isHealthy = !error;

      if (isHealthy) {
        return this.getStatus(key, true, { message: 'Database is connected' });
      }

      throw new HealthCheckError(
        'Supabase check failed',
        this.getStatus(key, false, { message: error?.message || 'Unknown error' }),
      );
    } catch (error) {
      throw new HealthCheckError(
        'Supabase check failed',
        this.getStatus(key, false, { message: error.message }),
      );
    }
  }
}
