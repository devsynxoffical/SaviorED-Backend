import React from 'react';
import { Link } from 'react-router-dom';
import { Mail, Shield, Twitter, Facebook, Instagram } from 'lucide-react';

const Footer = () => {
  return (
    <footer className="footer-section">
      <div className="container">
        <div className="footer-grid">
          <div className="footer-brand">
            <Link to="/" className="flex items-center gap-2 mb-4">
              <Shield className="text-accent" size={24} color="#d4af37" />
              <span className="text-xl font-heading font-bold gradient-text">SaviorED</span>
            </Link>
            <p className="footer-description">
              Empowering children to focus on their studies through rewarding gamification. Turn study time into castle building!
            </p>
          </div>

          <div className="footer-links">
            <h4>Quick Links</h4>
            <ul>
              <li><Link to="/">Home</Link></li>
              <li><Link to="/contact">Contact Us</Link></li>
              <li><Link to="/contact">Support</Link></li>
            </ul>
          </div>

          <div className="footer-contact">
            <h4>Contact Info</h4>
            <div className="contact-item">
              <Mail size={18} color="#d4af37" />
              <a href="mailto:info@saviored.com">info@saviored.com</a>
            </div>
            <div className="social-links mt-4">
              <a href="#"><Twitter size={20} /></a>
              <a href="#"><Facebook size={20} /></a>
              <a href="#"><Instagram size={20} /></a>
            </div>
          </div>
        </div>

        <div className="footer-bottom">
          <p>&copy; {new Date().getFullYear()} SaviorED. All rights reserved.</p>
        </div>
      </div>

      <style dangerouslySetInnerHTML={{
        __html: `
        .footer-section {
          background: #080f08;
          padding: 80px 0 30px;
          border-top: 1px solid var(--color-border);
        }
        .footer-grid {
          display: grid;
          grid-template-columns: 2fr 1fr 1fr;
          gap: 4rem;
          margin-bottom: 3rem;
        }
        @media (max-width: 768px) {
          .footer-grid {
            grid-template-columns: 1fr;
            gap: 2rem;
          }
        }
        .footer-brand h4, .footer-links h4, .footer-contact h4 {
          font-family: var(--font-heading);
          color: var(--color-accent);
          margin-bottom: 1.5rem;
          font-size: 1.1rem;
        }
        .footer-description {
          color: var(--color-text-muted);
          max-width: 300px;
        }
        .footer-links ul {
          list-style: none;
        }
        .footer-links li {
          margin-bottom: 0.8rem;
        }
        .footer-links a {
          color: var(--color-text-muted);
          font-size: 0.9rem;
        }
        .footer-links a:hover {
          color: var(--color-accent);
          padding-left: 5px;
        }
        .contact-item {
          display: flex;
          align-items: center;
          gap: 0.8rem;
          color: var(--color-text-muted);
          font-size: 0.9rem;
        }
        .social-links {
          display: flex;
          gap: 1.2rem;
        }
        .social-links a {
          color: var(--color-text-muted);
          transition: var(--transition);
        }
        .social-links a:hover {
          color: var(--color-accent);
          transform: translateY(-3px);
        }
        .footer-bottom {
          padding-top: 2rem;
          border-top: 1px solid rgba(255, 255, 255, 0.05);
          text-align: center;
          color: var(--color-text-muted);
          font-size: 0.85rem;
        }
        .mb-4 { margin-bottom: 1rem; }
        .text-xl { font-size: 1.25rem; }
      `}} />
    </footer>
  );
};

export default Footer;
