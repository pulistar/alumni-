import { Module, Global } from '@nestjs/common';
import { SupabaseService } from './supabase.service';

/**
 * Database Module - Infrastructure Layer
 *
 * @Global decorator makes this module available throughout the application
 * Implements Dependency Injection pattern
 *
 * @responsibility Provide database access to all modules
 */
@Global()
@Module({
  providers: [SupabaseService],
  exports: [SupabaseService],
})
export class DatabaseModule {}
