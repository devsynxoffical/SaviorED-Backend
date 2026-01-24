import { useState } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { useNavigate, useLocation } from 'react-router-dom';
import './Header.css';

const Header = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  const navItems = [
    { path: '/', label: 'Dashboard', icon: 'dashboard' },
    { path: '/users', label: 'Users', icon: 'people' },
    { path: '/focus-sessions', label: 'Focus Sessions', icon: 'timer' },
    { path: '/castle-grounds', label: 'Castle Grounds', icon: 'domain' },
    { path: '/leaderboard', label: 'Leaderboard', icon: 'leaderboard' },
    { path: '/treasure-chests', label: 'Treasure Chests', icon: 'inventory_2' },
  ];

  const handleNavigate = (path) => {
    navigate(path);
    setIsMobileMenuOpen(false);
  };

  return (
    <header className="admin-header">
      <div className="header-content">
        <div className="mobile-header-top">
          <div className="logo-section" onClick={() => navigate('/')}>
            <div className="mini-logo">S</div>
            <span className="logo-text">SaviorED</span>
          </div>

          <button
            className="mobile-menu-toggle"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          >
            <span className="material-icons">
              {isMobileMenuOpen ? 'close' : 'menu'}
            </span>
          </button>
        </div>

        <nav className={`header-nav ${isMobileMenuOpen ? 'mobile-open' : ''}`}>
          {navItems.map((item) => (
            <button
              key={item.path}
              className={`nav-button ${location.pathname === item.path ? 'active' : ''}`}
              onClick={() => handleNavigate(item.path)}
            >
              <span className="material-icons nav-icon">{item.icon}</span>
              <span className="nav-label">{item.label}</span>
            </button>
          ))}

          {/* Mobile Logout (visible only in mobile menu) */}
          <button className="nav-button mobile-only logout-mobile" onClick={handleLogout}>
            <span className="material-icons nav-icon">logout</span>
            <span className="nav-label">Logout</span>
          </button>
        </nav>
      </div>
    </header>
  );
};

export default Header;

