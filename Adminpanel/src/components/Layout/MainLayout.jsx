import { useAuth } from '../../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import Header from './Header';
import './MainLayout.css';

const MainLayout = ({ children }) => {
  const { logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    await logout();
    navigate('/login');
  };

  return (
    <div className="main-layout">
      <Header />
      <main className="main-content">
        {children}
      </main>
      <button className="logout-button-bottom" onClick={handleLogout} title="Logout">
        <span className="material-icons">logout</span>
        <span>Logout</span>
      </button>
    </div>
  );
};

export default MainLayout;

