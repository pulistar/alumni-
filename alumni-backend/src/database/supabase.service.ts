import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

/**
 * Supabase Service - Infrastructure Layer
 *
 * Implements Singleton Pattern for Supabase client
 * Provides a clean abstraction over Supabase SDK
 *
 * @responsibility Manage Supabase client instance and provide database access
 */
@Injectable()
export class SupabaseService implements OnModuleInit {
  private readonly logger = new Logger(SupabaseService.name);
  private client: SupabaseClient;

  constructor(private readonly configService: ConfigService) {}

  /**
   * Initialize Supabase client on module initialization
   * Implements Dependency Inversion Principle
   */
  async onModuleInit() {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseKey = this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseKey) {
      throw new Error(
        'Supabase configuration is missing. Please check your environment variables.',
      );
    }

    this.client = createClient(supabaseUrl, supabaseKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    this.logger.log('✅ Supabase client initialized successfully');
  }

  /**
   * Get Supabase client instance
   * @returns SupabaseClient instance
   */
  getClient(): SupabaseClient {
    if (!this.client) {
      throw new Error('Supabase client not initialized');
    }
    return this.client;
  }

  /**
   * Execute a query with error handling
   * Implements Template Method Pattern
   */
  async executeQuery<T>(
    queryFn: (client: SupabaseClient) => Promise<{ data: T; error: any }>,
  ): Promise<T> {
    try {
      const { data, error } = await queryFn(this.client);

      if (error) {
        this.logger.error(`Database query error: ${error.message}`, error.stack);
        throw new Error(`Database error: ${error.message}`);
      }

      return data;
    } catch (error) {
      this.logger.error(`Unexpected error in query execution`, error.stack);
      throw error;
    }
  }
}
