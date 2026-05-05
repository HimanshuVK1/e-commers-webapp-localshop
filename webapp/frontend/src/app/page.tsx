'use client';

import { useEffect, useState, useRef } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import api from '@/lib/api';
import { useCartStore } from '@/store/useCartStore';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { ShoppingCart, Star, Zap, ArrowRight, X } from 'lucide-react';

export default function Home() {
  const [products, setProducts] = useState<any[]>([]);
  const [filteredProducts, setFilteredProducts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [category, setCategory] = useState('all');
  const addItem = useCartStore((state) => state.addItem);
  const searchParams = useSearchParams();
  const router = useRouter();
  const searchQuery = searchParams.get('search');
  
  const productsRef = useRef<HTMLDivElement>(null);
  const categoriesRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setLoading(true);
    const searchPart = searchQuery ? `&search=${encodeURIComponent(searchQuery)}` : '';
    api.get(`/products?limit=50${searchPart}`)
      .then((res) => {
        setProducts(res.data.data);
        setFilteredProducts(res.data.data);
      })
      .catch((err) => console.error(err))
      .finally(() => setLoading(false));
  }, [searchQuery]);

  useEffect(() => {
    if (category === 'all') {
      setFilteredProducts(products);
    } else {
      setFilteredProducts(products.filter(p => p.category.toLowerCase() === category.toLowerCase()));
    }
  }, [category, products]);

  const clearSearch = () => {
    const params = new URLSearchParams(searchParams.toString());
    params.delete('search');
    router.push(`/?${params.toString()}`);
  };

  const handleAddToCart = async (product: any) => {
    try {
      await api.post('/cart/add', {
        productId: product._id,
        name: product.name,
        price: product.price,
        quantity: 1
      });
      addItem({
        productId: product._id,
        name: product.name,
        price: product.price,
        quantity: 1
      });
    } catch (err) {
      alert('Login first to add to cart');
    }
  };

  return (
    <div className="space-y-16 pb-20">
      {/* Hero Section */}
      <section className="relative overflow-hidden rounded-[2.5rem] bg-[#0f172a] py-24 px-8 md:px-16 text-white shadow-2xl">
        <div className="relative z-10 max-w-3xl space-y-8">
          <Badge className="bg-blue-500/20 text-blue-400 border-blue-500/30 px-4 py-1 text-sm backdrop-blur-md">
            ✨ Launching Summer Collection 2024
          </Badge>
          <h1 className="text-6xl md:text-7xl font-black tracking-tight leading-[1.1]">
            Elevate Your <br /> 
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-indigo-400">Digital Realm</span>
          </h1>
          <p className="text-xl text-slate-400 max-w-xl leading-relaxed">
            Experience the fusion of high-performance technology and premium design. 
            Curated products for the modern lifestyle.
          </p>
        </div>
        
        {/* Decorative elements */}
        <div className="absolute top-0 right-0 -translate-y-1/2 translate-x-1/3 w-[800px] h-[800px] bg-blue-600/10 rounded-full blur-[120px]" />
        <div className="absolute -bottom-24 -right-24 w-[400px] h-[400px] bg-indigo-600/10 rounded-full blur-[100px]" />
      </section>

      {/* Categories Section */}
      <section ref={categoriesRef} className="space-y-8 scroll-mt-24">
        <div className="text-center space-y-4">
          <h2 className="text-4xl font-black tracking-tight">Browse by Category</h2>
          <p className="text-muted-foreground text-lg">Find exactly what you're looking for.</p>
        </div>

        <Tabs defaultValue="all" className="w-full flex flex-col items-center" onValueChange={setCategory}>
          <TabsList className="bg-slate-100 p-1 rounded-full h-14">
            <TabsTrigger value="all" className="rounded-full px-8 data-[state=active]:bg-white data-[state=active]:shadow-md h-12">All</TabsTrigger>
            <TabsTrigger value="electronics" className="rounded-full px-8 data-[state=active]:bg-white data-[state=active]:shadow-md h-12">Electronics</TabsTrigger>
            <TabsTrigger value="clothing" className="rounded-full px-8 data-[state=active]:bg-white data-[state=active]:shadow-md h-12">Clothing</TabsTrigger>
            <TabsTrigger value="home" className="rounded-full px-8 data-[state=active]:bg-white data-[state=active]:shadow-md h-12">Home</TabsTrigger>
            <TabsTrigger value="books" className="rounded-full px-8 data-[state=active]:bg-white data-[state=active]:shadow-md h-12">Books</TabsTrigger>
          </TabsList>
        </Tabs>
      </section>

      {/* Product Grid */}
      <section ref={productsRef} className="space-y-10 scroll-mt-24">
        <div className="flex flex-col md:flex-row md:items-end justify-between border-b pb-6 gap-4">
          <div className="space-y-1">
            <h3 className="text-3xl font-bold tracking-tight">
              {category === 'all' ? 'All Products' : `${category.charAt(0).toUpperCase() + category.slice(1)}`}
            </h3>
            {searchQuery && (
              <div className="flex items-center gap-2 text-blue-600 font-medium">
                <span>Search results for "{searchQuery}"</span>
                <button 
                  onClick={clearSearch}
                  className="p-1 hover:bg-blue-50 rounded-full transition-colors"
                  title="Clear search"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>
            )}
            <p className="text-muted-foreground">Showing {filteredProducts.length} premium items.</p>
          </div>
          <Button variant="outline" className="rounded-full font-bold border-2" onClick={() => {
            setCategory('all');
            if (searchQuery) clearSearch();
          }}>
            Reset Filters
          </Button>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
            {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
              <div key={i} className="h-[400px] w-full bg-slate-50 animate-pulse rounded-3xl" />
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
            {filteredProducts.map((product) => (
              <Card key={product._id} className="group border-none shadow-sm hover:shadow-2xl transition-all duration-500 rounded-[2rem] bg-white overflow-hidden flex flex-col h-full">
                <CardHeader className="p-0 relative h-72 overflow-hidden bg-slate-100">
                  <img 
                    src={product.images[0]} 
                    alt={product.name} 
                    referrerPolicy="no-referrer"
                    className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110" 
                  />
                  <div className="absolute top-4 left-4">
                    <Badge className="bg-white/90 text-slate-900 hover:bg-white backdrop-blur-md border-none px-3 py-1 font-bold">
                      {product.category}
                    </Badge>
                  </div>
                  <Button 
                    size="icon" 
                    variant="secondary"
                    className="absolute top-4 right-4 bg-white/90 backdrop-blur-md rounded-full h-10 w-10 opacity-0 group-hover:opacity-100 transition-all duration-300 translate-y-2 group-hover:translate-y-0 shadow-lg"
                  >
                    <Zap className="h-5 w-5 text-amber-500 fill-amber-500" />
                  </Button>
                </CardHeader>
                <CardContent className="p-6 flex-grow space-y-3">
                  <div className="flex justify-between items-start">
                    <CardTitle className="text-xl font-bold group-hover:text-blue-600 transition-colors leading-tight">
                      {product.name}
                    </CardTitle>
                    <div className="flex items-center bg-amber-50 text-amber-600 px-2 py-1 rounded-lg text-xs font-black">
                      <Star className="h-3 w-3 fill-amber-500 mr-1" />
                      {product.rating}
                    </div>
                  </div>
                  <p className="text-sm text-muted-foreground line-clamp-2 leading-relaxed">
                    {product.description}
                  </p>
                </CardContent>
                <CardFooter className="p-6 pt-0 flex items-center justify-between">
                  <div className="flex flex-col">
                    <span className="text-xs text-muted-foreground font-bold uppercase tracking-wider">Price</span>
                    <span className="text-2xl font-black text-slate-900">${product.price}</span>
                  </div>
                  <Button 
                    onClick={() => handleAddToCart(product)}
                    className="rounded-2xl bg-slate-900 hover:bg-blue-600 transition-all duration-300 shadow-xl shadow-slate-200 px-6 h-12 font-bold"
                  >
                    <ShoppingCart className="h-4 w-4 mr-2" />
                    Add to Cart
                  </Button>
                </CardFooter>
              </Card>
            ))}
          </div>
        )}
      </section>
      
      {/* Visual Density Items - Promo Banner */}
      <section className="bg-gradient-to-r from-blue-600 to-indigo-700 rounded-[2.5rem] p-12 text-white flex flex-col md:flex-row items-center justify-between gap-8 shadow-2xl">
        <div className="space-y-4 max-w-lg">
          <h2 className="text-4xl font-black">Get 20% Off Your First Order</h2>
          <p className="text-blue-100 text-lg">Join our community and get exclusive access to limited edition product drops and special seasonal offers.</p>
        </div>
        <div className="flex gap-4 w-full md:w-auto">
          <input type="email" placeholder="Enter your email" className="bg-white/10 border-white/20 text-white placeholder:text-blue-200 rounded-2xl px-6 h-14 flex-grow outline-none focus:ring-2 focus:ring-white/50" />
          <Button className="bg-white text-blue-600 hover:bg-blue-50 h-14 px-8 rounded-2xl font-black text-lg">Join</Button>
        </div>
      </section>
    </div>
  );
}
