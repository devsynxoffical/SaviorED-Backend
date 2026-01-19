import { useState, useEffect } from 'react';
import { dashboardAPI } from '../services/api';
import './Dashboard.css';

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [activity, setActivity] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      setLoading(true);
      const [statsRes, activityRes] = await Promise.all([
        dashboardAPI.getStats(),
        dashboardAPI.getRecentActivity(),
      ]);
      setStats(statsRes.data.stats || statsRes.data);
      setActivity(activityRes.data.activities || activityRes.data || []);
    } catch (error) {
      console.error('Error loading dashboard:', error);
      // Fallback only if absolutely necessary, but we want real data
      setStats(null);
      setActivity([]);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="dashboard-loading">Loading dashboard...</div>;
  }

  const statCards = [
    {
      title: 'Total Users',
      value: stats?.totalUsers || 0,
      icon: '👥',
      color: '#3b82f6',
    },
    {
      title: 'Active Users',
      value: stats?.activeUsers || 0,
      icon: '✅',
      color: '#10b981',
    },
    {
      title: 'Focus Sessions',
      value: stats?.totalFocusSessions || 0,
      icon: '⏱️',
      color: '#f59e0b',
    },
    {
      title: 'Total Focus Hours',
      value: stats?.totalFocusHours?.toFixed(1) || 0,
      icon: '⏰',
      color: '#8b5cf6',
    },
    {
      title: 'Castles Built',
      value: stats?.totalCastles || 0,
      icon: '🏰',
      color: '#ec4899',
    },
    {
      title: 'Treasure Chests',
      value: stats?.totalTreasureChests || 0,
      icon: '💎',
      color: '#06b6d4',
    },
  ];

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h2>Dashboard Overview</h2>
        <p>Welcome to SaviorED Admin Panel</p>
      </div>

      <div className="stats-grid">
        {statCards.map((stat, index) => (
          <div key={index} className="stat-card">
            <div className="stat-icon" style={{ backgroundColor: `${stat.color}20` }}>
              <span style={{ fontSize: '32px' }}>{stat.icon}</span>
            </div>
            <div className="stat-content">
              <h3>{stat.value.toLocaleString()}</h3>
              <p>{stat.title}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="dashboard-sections">
        <div className="section-card">
          <h3>Recent Activity</h3>
          <div className="activity-list">
            {activity.length > 0 ? (
              activity.map((item, index) => (
                <div key={index} className="activity-item">
                  <span className="activity-icon">{item.icon || '📝'}</span>
                  <div className="activity-content">
                    <p className="activity-text">{item.description || 'No recent activity'}</p>
                    <span className="activity-time">{item.time || 'Just now'}</span>
                  </div>
                </div>
              ))
            ) : (
              <div className="no-activity">No recent activity</div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;

