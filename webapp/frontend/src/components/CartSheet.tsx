'use client';

import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
  SheetFooter,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { ShoppingCart, Trash2, Plus, Minus } from "lucide-react";
import { useCartStore } from "@/store/useCartStore";
import api from "@/lib/api";
import { useRouter } from "next/navigation";
import { Separator } from "@/components/ui/separator";
import { useEffect, useState } from "react";

export function CartSheet() {
  const { items, addItem, removeItem, updateQty, clearCart } = useCartStore();
  const router = useRouter();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const itemCount = items.reduce((acc, item) => acc + item.quantity, 0);

  const handleCheckout = async () => {
    if (items.length === 0) return;
    try {
      await api.post('/orders', {
        items,
        total,
        address: '123 Default Street, City' // In a real app, this would be from a form
      });
      clearCart();
      await api.delete('/cart/clear');
      router.push('/orders');
    } catch (err) {
      alert('Checkout failed. Please login first.');
      router.push('/login');
    }
  };

  return (
    <Sheet>
      <SheetTrigger asChild>
        <Button variant="outline" size="icon" className="relative">
          <ShoppingCart className="h-5 w-5" />
          {mounted && itemCount > 0 && (
            <span className="absolute -top-2 -right-2 bg-primary text-primary-foreground text-[10px] font-bold rounded-full h-5 w-5 flex items-center justify-center border-2 border-background">
              {itemCount}
            </span>
          )}
        </Button>
      </SheetTrigger>
      <SheetContent className="w-full sm:max-w-md flex flex-col">
        <SheetHeader>
          <SheetTitle className="flex items-center gap-2">
            <ShoppingCart className="h-5 w-5" />
            Your Cart
          </SheetTitle>
        </SheetHeader>
        <div className="flex-1 overflow-y-auto py-6">
          {items.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-muted-foreground">
              <ShoppingCart className="h-12 w-12 mb-4 opacity-20" />
              <p>Your cart is empty</p>
            </div>
          ) : (
            <div className="space-y-6">
              {items.map((item) => (
                <div key={item.productId} className="flex gap-4">
                  <div className="h-16 w-16 rounded bg-muted flex-shrink-0" /> {/* Placeholder for image */}
                  <div className="flex-1 min-w-0">
                    <h4 className="text-sm font-medium truncate">{item.name}</h4>
                    <p className="text-sm text-muted-foreground">${item.price}</p>
                    <div className="flex items-center gap-2 mt-2">
                      <Button 
                        variant="outline" 
                        size="icon" 
                        className="h-7 w-7"
                        onClick={() => updateQty(item.productId, item.quantity - 1)}
                      >
                        <Minus className="h-3 w-3" />
                      </Button>
                      <span className="text-sm w-4 text-center">{item.quantity}</span>
                      <Button 
                        variant="outline" 
                        size="icon" 
                        className="h-7 w-7"
                        onClick={() => updateQty(item.productId, item.quantity + 1)}
                      >
                        <Plus className="h-3 w-3" />
                      </Button>
                    </div>
                  </div>
                  <div className="text-right flex flex-col justify-between">
                    <p className="text-sm font-bold">${(item.price * item.quantity).toFixed(2)}</p>
                    <Button 
                      variant="ghost" 
                      size="icon" 
                      className="h-8 w-8 text-destructive hover:text-destructive hover:bg-destructive/10"
                      onClick={() => updateQty(item.productId, 0)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
        {items.length > 0 && (
          <div className="pt-6 space-y-4">
            <Separator />
            <div className="flex justify-between text-lg font-bold">
              <span>Total</span>
              <span>${total.toFixed(2)}</span>
            </div>
            <SheetFooter>
              <Button className="w-full h-12 text-base font-bold" onClick={handleCheckout}>
                Checkout Now
              </Button>
            </SheetFooter>
          </div>
        )}
      </SheetContent>
    </Sheet>
  );
}
