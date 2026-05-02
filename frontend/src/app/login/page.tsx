'use client';

import { useState } from 'react';
import api from '@/lib/api';
import { useUserStore } from '@/store/useUserStore';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Label } from '@/components/ui/label';
import { Loader2, Mail, Lock, User, Phone, MapPin } from 'lucide-react';

export default function AuthPage() {
  const [loading, setLoading] = useState(false);
  const login = useUserStore((state) => state.login);
  const router = useRouter();

  const handleAuth = async (e: React.FormEvent, type: 'login' | 'register') => {
    e.preventDefault();
    setLoading(true);
    const formData = new FormData(e.currentTarget as HTMLFormElement);
    const data = Object.fromEntries(formData);

    try {
      const endpoint = type === 'login' ? '/users/login' : '/users/register';
      const res = await api.post(endpoint, data);
      login(res.data.data.user, res.data.data.token);
      router.push('/');
    } catch (err: any) {
      alert(err.response?.data?.error || 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <Card className="w-full max-w-md border-none shadow-2xl rounded-2xl overflow-hidden">
        <div className="h-2 bg-primary" />
        <CardHeader className="space-y-1 text-center pt-8">
          <CardTitle className="text-3xl font-black tracking-tight">Account</CardTitle>
          <CardDescription>
            Enter your credentials to access your account
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs defaultValue="login" className="w-full">
            <TabsList className="grid w-full grid-cols-2 mb-8">
              <TabsTrigger value="login">Login</TabsTrigger>
              <TabsTrigger value="register">Register</TabsTrigger>
            </TabsList>
            
            <TabsContent value="login">
              <form onSubmit={(e) => handleAuth(e, 'login')} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="email-login">Email</Label>
                  <div className="relative">
                    <Mail className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                    <Input id="email-login" name="email" type="email" placeholder="name@example.com" className="pl-10 h-11" required />
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <Label htmlFor="password-login">Password</Label>
                    <Button variant="link" className="px-0 font-normal text-xs text-blue-600">Forgot password?</Button>
                  </div>
                  <div className="relative">
                    <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                    <Input id="password-login" name="password" type="password" placeholder="••••••••" className="pl-10 h-11" required />
                  </div>
                </div>
                <Button type="submit" className="w-full h-11 font-bold mt-2" disabled={loading}>
                  {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                  Sign In
                </Button>
              </form>
            </TabsContent>

            <TabsContent value="register">
              <form onSubmit={(e) => handleAuth(e, 'register')} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="name">Full Name</Label>
                  <div className="relative">
                    <User className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                    <Input id="name" name="name" placeholder="John Doe" className="pl-10 h-11" required />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="email-reg">Email</Label>
                  <div className="relative">
                    <Mail className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                    <Input id="email-reg" name="email" type="email" placeholder="name@example.com" className="pl-10 h-11" required />
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="phone">Phone</Label>
                    <div className="relative">
                      <Phone className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                      <Input id="phone" name="phone" placeholder="+123..." className="pl-10 h-11" />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="password-reg">Password</Label>
                    <div className="relative">
                      <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                      <Input id="password-reg" name="password" type="password" placeholder="••••••••" className="pl-10 h-11" required />
                    </div>
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="address">Address</Label>
                  <div className="relative">
                    <MapPin className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                    <Input id="address" name="address" placeholder="123 Luxury St, New York" className="pl-10 h-11" />
                  </div>
                </div>
                <Button type="submit" className="w-full h-11 font-bold mt-2" disabled={loading}>
                  {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                  Create Account
                </Button>
              </form>
            </TabsContent>
          </Tabs>
        </CardContent>
        <CardFooter className="bg-slate-50/50 border-t py-4 justify-center">
          <p className="text-xs text-muted-foreground">
            By continuing, you agree to our Terms of Service.
          </p>
        </CardFooter>
      </Card>
    </div>
  );
}
