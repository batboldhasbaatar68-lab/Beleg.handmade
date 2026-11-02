import { sqliteTable, text, integer, uniqueIndex } from 'drizzle-orm/sqlite-core';
export const orders = sqliteTable('orders', {
  id: text('id').primaryKey(), userId: text('user_id').notNull(), requestKey: text('request_key').notNull(),
  productId: text('product_id').notNull(), quantity: integer('quantity').notNull(),
  unitPrice: integer('unit_price').notNull(), total: integer('total').notNull(),
  name: text('name').notNull(), phone: text('phone').notNull(), delivery: text('delivery').notNull(),
  address: text('address').notNull(), note: text('note').notNull(),
  status: text('status').notNull().default('pending'), createdAt: text('created_at').notNull(),
}, (t) => [uniqueIndex('orders_request_user').on(t.userId,t.requestKey)]);
