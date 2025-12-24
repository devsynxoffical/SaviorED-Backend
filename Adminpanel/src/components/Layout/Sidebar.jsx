import { NavLink } from 'react-router-dom';
import './Sidebar.css';

const Sidebar = () => {
  const menuItems = [
    { path: '/', label: 'Dashboard', icon: '📊' },
    { path: '/users', label: 'Users', icon: '👥' },
    { path: '/focus-sessions', label: 'Focus Sessions', icon: '⏱️' },
    { path: '/castle-grounds', label: 'Castle Grounds', icon: '🏰' },
    { path: '/leaderboard', label: 'Leaderboard', icon: '🏆' },
    { path: '/treasure-chests', label: 'Treasure Chests', icon: '💎' },
  ];

  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <h2>SaviorED Admin</h2>
      </div>
      <nav className="sidebar-nav">
        <ul>
          {menuItems.map((item) => (
            <li key={item.path}>
              <NavLink
                to={item.path}
                className={({ isActive }) => (isActive ? 'active' : '')}
              >
                <span className="icon">{item.icon}</span>
                <span className="label">{item.label}</span>
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>
    </aside>
  );
};

export default Sidebar;

