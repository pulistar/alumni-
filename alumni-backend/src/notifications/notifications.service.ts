import { Injectable, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { ServiceAccount } from 'firebase-admin';
import * as path from 'path';
import * as fs from 'fs';

@Injectable()
export class NotificationsService {
    private readonly logger = new Logger(NotificationsService.name);
    private firebaseInitialized = false;

    constructor() {
        try {
            // Inicializar Firebase Admin SDK
            const serviceAccountPath = path.join(process.cwd(), 'config', 'firebase-admin-key.json');

            if (!fs.existsSync(serviceAccountPath)) {
                this.logger.warn('Firebase Admin key not found. Push notifications will be disabled.');
                return;
            }

            const serviceAccountContent = fs.readFileSync(serviceAccountPath, 'utf8');
            const serviceAccount: ServiceAccount = JSON.parse(serviceAccountContent);

            if (!admin.apps.length) {
                admin.initializeApp({
                    credential: admin.credential.cert(serviceAccount),
                });
                this.firebaseInitialized = true;
                this.logger.log('Firebase Admin SDK initialized');
            }
        } catch (error) {
            this.logger.error(`Failed to initialize Firebase Admin: ${error.message}`);
            this.firebaseInitialized = false;
        }
    }

    /**
     * Enviar notificación push a un dispositivo específico
     */
    async sendPushNotification(
        fcmToken: string,
        title: string,
        body: string,
        data?: { [key: string]: string },
    ): Promise<boolean> {
        if (!this.firebaseInitialized) {
            this.logger.warn('Firebase not initialized. Skipping push notification.');
            return false;
        }

        try {
            const message: admin.messaging.Message = {
                notification: {
                    title,
                    body,
                },
                data: data || {},
                token: fcmToken,
                android: {
                    priority: 'high',
                    notification: {
                        sound: 'default',
                        channelId: 'default',
                    },
                },
            };

            const response = await admin.messaging().send(message);
            this.logger.log(`Notificación enviada exitosamente: ${response}`);
            return true;
        } catch (error) {
            this.logger.error(`Error enviando notificación: ${error.message}`);
            return false;
        }
    }

    /**
     * Enviar notificación de habilitación para proceso de grado
     */
    async sendHabilitacionNotification(fcmToken: string, nombreCompleto: string): Promise<boolean> {
        return this.sendPushNotification(
            fcmToken,
            '¡Felicitaciones! 🎓',
            `${nombreCompleto}, has sido habilitado para el proceso de grado. Ingresa a la app para más información.`,
            {
                type: 'habilitacion',
                action: 'open_prealumni',
            },
        );
    }

    /**
     * Enviar notificación a múltiples dispositivos
     */
    async sendMulticastNotification(
        fcmTokens: string[],
        title: string,
        body: string,
        data?: { [key: string]: string },
    ): Promise<{ successCount: number; failureCount: number }> {
        if (!this.firebaseInitialized) {
            this.logger.warn('Firebase not initialized. Skipping push notifications.');
            return { successCount: 0, failureCount: fcmTokens.length };
        }

        try {
            const message: admin.messaging.MulticastMessage = {
                notification: {
                    title,
                    body,
                },
                data: data || {},
                tokens: fcmTokens,
                android: {
                    priority: 'high',
                    notification: {
                        sound: 'default',
                        channelId: 'default',
                    },
                },
            };

            const response = await admin.messaging().sendEachForMulticast(message);
            this.logger.log(
                `Notificaciones enviadas: ${response.successCount} exitosas, ${response.failureCount} fallidas`,
            );

            return {
                successCount: response.successCount,
                failureCount: response.failureCount,
            };
        } catch (error) {
            this.logger.error(`Error enviando notificaciones múltiples: ${error.message}`);
            return { successCount: 0, failureCount: fcmTokens.length };
        }
    }
}
