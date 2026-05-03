'use client';

import { useEffect, useState } from 'react';
import api from '@/lib/api';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Package, Clock, CheckCircle, Truck, XCircle } from 'lucide-react';
import { Separator } from '@/components/ui/separator';

const statusIcons: Record<string, any> = {
  pending: Clock,
  confirmed: CheckCircle,
  shipped: Truck,
  delivered: CheckCircle,
  cancelled: XCircle
};

const statusColors: Record<string, string> = {
  pending: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  confirmed: 'bg-blue-100 text-blue-800 border-blue-200',
  shipped: 'bg-purple-100 text-purple-800 border-purple-200',
  delivered: 'bg-green-100 text-green-800 border-green-200',
  cancelled: 'bg-red-100 text-red-800 border-red-200'
};

export default function Orders() {
  const [orders, setOrders] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/orders')
      .then((res) => setOrders(res.data.data))
      .catch((err) => console.error(err))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="max-w-5xl mx-auto space-y-8">
      <div className="flex flex-col gap-2">
        <h1 className="text-4xl font-extrabold tracking-tight">Order History</h1>
        <p className="text-muted-foreground">Manage and track your recent purchases.</p>
      </div>

      {loading ? (
        <div className="space-y-4">
          {[1, 2].map(i => <div key={i} className="h-40 w-full bg-slate-50 animate-pulse rounded-xl" />)}
        </div>
      ) : orders.length === 0 ? (
        <Card className="border-dashed py-12">
          <CardContent className="flex flex-col items-center justify-center text-center">
            <Package className="h-12 w-12 text-muted-foreground mb-4 opacity-20" />
            <h3 className="text-lg font-semibold">No orders found</h3>
            <p className="text-muted-foreground max-w-xs mx-auto mt-2">
              You haven't placed any orders yet. Start shopping to see your history here!
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6">
          {orders.map((order) => {
            const StatusIcon = statusIcons[order.status] || Package;
            return (
              <Card key={order.id} className="overflow-hidden border-none shadow-md hover:shadow-lg transition-shadow">
                <CardHeader className="bg-slate-50/50 flex flex-row items-center justify-between py-4">
                  <div className="space-y-1">
                    <CardTitle className="text-sm font-medium text-muted-foreground">
                      Order <span className="text-foreground">#{order.id.split('-')[0].toUpperCase()}</span>
                    </CardTitle>
                    <CardDescription>
                      Placed on {new Date(order.createdAt).toLocaleDateString(undefined, { dateStyle: 'long' })}
                    </CardDescription>
                  </div>
                  <Badge className={`${statusColors[order.status]} border flex items-center gap-1.5 px-3 py-1`}>
                    <StatusIcon className="h-3.5 w-3.5" />
                    {order.status.toUpperCase()}
                  </Badge>
                </CardHeader>
                <CardContent className="pt-6">
                  <div className="grid md:grid-cols-2 gap-8">
                    <div className="space-y-4">
                      <h4 className="text-sm font-bold uppercase tracking-wider text-muted-foreground">Items</h4>
                      <div className="space-y-3">
                        {order.items.map((item: any) => (
                          <div key={item.productId} className="flex justify-between items-center text-sm">
                            <span className="font-medium">{item.name} <span className="text-muted-foreground ml-1">× {item.quantity}</span></span>
                            <span className="font-bold">${(item.price * item.quantity).toFixed(2)}</span>
                          </div>
                        ))}
                      </div>
                      <Separator className="my-4" />
                      <div className="flex justify-between items-center">
                        <span className="text-base font-bold">Total Amount</span>
                        <span className="text-xl font-black text-blue-600">${order.total.toFixed(2)}</span>
                      </div>
                    </div>
                    <div className="space-y-4">
                      <h4 className="text-sm font-bold uppercase tracking-wider text-muted-foreground">Shipping Details</h4>
                      <div className="bg-slate-50 p-4 rounded-lg border text-sm space-y-2">
                        <p className="font-medium text-slate-900">Delivery Address:</p>
                        <p className="text-muted-foreground leading-relaxed">{order.address}</p>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
