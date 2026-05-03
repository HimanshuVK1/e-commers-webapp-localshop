'use client';

import { useEffect, useState } from 'react';
import api from '@/lib/api';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { User, Mail, Phone, MapPin, Shield, Loader2, Save } from 'lucide-react';

export default function Profile() {
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    address: ''
  });

  useEffect(() => {
    api.get('/users/me')
      .then((res) => {
        setUser(res.data.data);
        setFormData({
          name: res.data.data.name || '',
          phone: res.data.data.phone || '',
          address: res.data.data.address || ''
        });
      })
      .catch((err) => console.error(err))
      .finally(() => setLoading(false));
  }, []);

  const handleUpdate = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const res = await api.put('/users/profile', formData);
      setUser(res.data.data);
      alert('Profile updated successfully!');
    } catch (err) {
      alert('Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  if (loading) return (
    <div className="flex items-center justify-center h-[60vh]">
      <Loader2 className="h-10 w-10 animate-spin text-blue-600" />
    </div>
  );

  return (
    <div className="max-w-4xl mx-auto space-y-8">
      <div className="flex items-center gap-4">
        <div className="h-20 w-20 rounded-full bg-blue-600 flex items-center justify-center text-white text-3xl font-black">
          {user.name.charAt(0).toUpperCase()}
        </div>
        <div>
          <h1 className="text-4xl font-black tracking-tight">{user.name}</h1>
          <p className="text-muted-foreground flex items-center gap-2 mt-1">
            <Mail className="h-4 w-4" /> {user.email}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        {/* Left Column - Stats */}
        <div className="space-y-6">
          <Card className="border-none shadow-md bg-slate-900 text-white overflow-hidden">
            <CardHeader className="pb-2">
              <CardTitle className="text-sm font-bold uppercase tracking-wider text-slate-400">Account Status</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-3">
                <Shield className="h-8 w-8 text-blue-400" />
                <div>
                  <p className="font-bold">Verified Member</p>
                  <p className="text-xs text-slate-400">Since 2024</p>
                </div>
              </div>
            </CardContent>
          </Card>
          
          <div className="grid grid-cols-1 gap-4">
             <Button variant="outline" className="justify-start h-12 rounded-xl" onClick={() => window.location.href='/orders'}>
                <Save className="mr-2 h-4 w-4" /> View Order History
             </Button>
          </div>
        </div>

        {/* Right Column - Edit Form */}
        <Card className="md:col-span-2 border-none shadow-xl rounded-[2rem]">
          <CardHeader>
            <CardTitle className="text-2xl font-bold">Personal Information</CardTitle>
            <CardDescription>Update your profile details and shipping address.</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleUpdate} className="space-y-6">
              <div className="space-y-2">
                <Label htmlFor="name">Full Name</Label>
                <div className="relative">
                  <User className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                  <Input 
                    id="name" 
                    value={formData.name}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                    className="pl-10 h-12 rounded-xl"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="phone">Phone Number</Label>
                <div className="relative">
                  <Phone className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                  <Input 
                    id="phone" 
                    value={formData.phone}
                    onChange={(e) => setFormData({...formData, phone: e.target.value})}
                    className="pl-10 h-12 rounded-xl"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="address">Default Shipping Address</Label>
                <div className="relative">
                  <MapPin className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                  <textarea 
                    id="address" 
                    rows={4}
                    value={formData.address}
                    onChange={(e) => setFormData({...formData, address: e.target.value})}
                    className="w-full pl-10 pt-3 border rounded-xl focus:ring-2 focus:ring-blue-600 outline-none transition"
                  />
                </div>
              </div>

              <Button type="submit" className="w-full h-12 rounded-xl font-bold text-lg" disabled={saving}>
                {saving ? <Loader2 className="h-5 w-5 animate-spin" /> : 'Save Changes'}
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
