import { useAuth } from '../../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import './Header.css';

const Header = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  return (
    <header className="admin-header">
      <div className="header-content">
        <div className="header-left">
          <h1>Admin Panel</h1>
        </div>
        <div className="header-right">
          <div className="user-info">
            <span className="user-name">{user?.name || user?.email || 'Admin'}</span>
            <button onClick={handleLogout} className="logout-btn">
              Logout
            </button>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;

