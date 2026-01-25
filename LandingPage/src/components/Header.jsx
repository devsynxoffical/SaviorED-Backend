import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X, Shield } from 'lucide-react';

const Header = () => {
    const [isScrolled, setIsScrolled] = useState(false);
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
    const location = useLocation();

    useEffect(() => {
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 50);
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const navLinks = [
        { title: 'Home', path: '/' },
        { title: 'Contact', path: '/contact' },
    ];

    return (
        <header className={`fixed top-0 left-0 w-full z-50 transition-all duration-300 ${isScrolled ? 'glass py-4 shadow-lg' : 'bg-transparent py-6'}`}>
            <div className="container flex justify-between items-center">
                <Link to="/" className="flex items-center gap-2">
                    <Shield className="text-accent" size={32} color="#d4af37" />
                    <span className="text-2xl font-heading font-bold gradient-text">SaviorED</span>
                </Link>

                {/* Desktop Nav */}
                <nav className="hidden md:flex items-center gap-8">
                    {navLinks.map((link) => (
                        <Link
                            key={link.title}
                            to={link.path}
                            className={`text-sm font-medium tracking-wider uppercase hover:text-accent transition-colors ${location.pathname === link.path ? 'text-accent' : 'text-text'}`}
                        >
                            {link.title}
                        </Link>
                    ))}
                    <Link to="/contact" className="btn-primary scale-90">Get Started</Link>
                </nav>

                {/* Mobile Toggle */}
                <button
                    className="md:hidden text-text"
                    onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
                >
                    {isMobileMenuOpen ? <X size={28} /> : <Menu size={28} />}
                </button>
            </div>

            {/* Mobile Menu */}
            {isMobileMenuOpen && (
                <div className="md:hidden absolute top-full left-0 w-full glass mt-2 p-6 flex flex-col gap-4 animate-in slide-in-from-top">
                    {navLinks.map((link) => (
                        <Link
                            key={link.title}
                            to={link.path}
                            onClick={() => setIsMobileMenuOpen(false)}
                            className="text-lg font-medium py-2 border-b border-white/10"
                        >
                            {link.title}
                        </Link>
                    ))}
                    <Link to="/contact" onClick={() => setIsMobileMenuOpen(false)} className="btn-primary text-center mt-4">Get Started</Link>
                </div>
            )}

            <style dangerouslySetInnerHTML={{
                __html: `
        header .container { display: flex; justify-content: space-between; align-items: center; max-width: 1200px; margin: 0 auto; padding: 0 2rem; }
        .flex { display: flex; }
        .items-center { align-items: center; }
        .gap-2 { gap: 0.5rem; }
        .gap-8 { gap: 2rem; }
        .hidden { display: none; }
        @media (min-width: 768px) { .md\\:flex { display: flex; } .md\\:hidden { display: none; } }
        .fixed { position: fixed; }
        .top-0 { top: 0; }
        .left-0 { left: 0; }
        .w-full { width: 100%; }
        .z-50 { z-index: 50; }
        .transition-all { transition-property: all; }
        .duration-300 { transition-duration: 300ms; }
        .py-4 { padding-top: 1rem; padding-bottom: 1rem; }
        .py-6 { padding-top: 1.5rem; padding-bottom: 1.5rem; }
        .text-2xl { font-size: 1.5rem; }
        .font-bold { font-weight: 700; }
        .text-sm { font-size: 0.875rem; }
        .font-medium { font-weight: 500; }
        .tracking-wider { letter-spacing: 0.05em; }
        .uppercase { text-transform: uppercase; }
        .scale-90 { transform: scale(0.9); }
        .relative { position: relative; }
        .absolute { position: absolute; }
        .top-full { top: 100%; }
        .mt-2 { margin-top: 0.5rem; }
        .mt-4 { margin-top: 1rem; }
        .p-6 { padding: 1.5rem; }
        .flex-col { flex-direction: column; }
        .gap-4 { gap: 1rem; }
        .text-lg { font-size: 1.125rem; }
        .py-2 { padding-top: 0.5rem; padding-bottom: 0.5rem; }
        .border-b { border-bottom-width: 1px; }
        .border-white\\/10 { border-color: rgba(255, 255, 255, 0.1); }
        .text-center { text-align: center; }
        .text-text { color: var(--color-text); }
        .text-accent { color: var(--color-accent); }
      `}} />
        </header>
    );
};

export default Header;
