import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { dashboardAPI, leaderboardAPI, treasureChestsAPI, settingsAPI } from '../services/api';
import treasureChestImage from '../assets/Images/Gemini_Generated_Image_ozm4fgozm4fgozm4-removebg-preview.png';
import castleBackgroundImage from '../assets/Images/generate a image like a castle and green trees and bushes around it amd montai in the back and clouds over that mountail_ and makei it gaming style not too muc animated looks natural.jpg';
import Modal from '../components/Modal';
import './Dashboard.css';

const Dashboard = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [profileModalOpen, setProfileModalOpen] = useState(false);
  const [selectedCommander, setSelectedCommander] = useState(null);

  // Local state for settings form
  const [chestSettings, setChestSettings] = useState({
    CHEST_UNLOCK_MINUTES: 60,
    CHEST_REWARD_COINS: 150,
    CHEST_REWARD_WOOD: 50,
    CHEST_REWARD_STONE: 25
  });

  const { data: statsData, isLoading: statsLoading } = useQuery({
    queryKey: ['dashboard', 'stats'],
    queryFn: async () => {
      const res = await dashboardAPI.getStats();
      return res.data.stats || res.data;
    },
  });

  const { data: settingsData } = useQuery({
    queryKey: ['admin', 'settings'],
    queryFn: async () => {
      const res = await settingsAPI.getAll();
      return res.data.settings || [];
    }
  });

  // Update local state when settings data is loaded
  useEffect(() => {
    if (settingsData) {
      const newSettings = { ...chestSettings };
      settingsData.forEach(s => {
        if (newSettings.hasOwnProperty(s.key)) {
          newSettings[s.key] = s.value;
        }
      });
      setChestSettings(newSettings);
    }
  }, [settingsData]);

  const updateSettingMutation = useMutation({
    mutationFn: async ({ key, value }) => {
      return await settingsAPI.update(key, { value });
    },
    onSuccess: () => {
      queryClient.invalidateQueries(['admin', 'settings']);
    }
  });

  const handleSettingChange = (key, value) => {
    setChestSettings(prev => ({ ...prev, [key]: value }));
  };

  const saveSetting = (key) => {
    updateSettingMutation.mutate({ key, value: chestSettings[key] });
  };

  const { data: activityData } = useQuery({
    queryKey: ['dashboard', 'activity'],
    queryFn: async () => {
      const res = await dashboardAPI.getRecentActivity();
      return res.data.activities || res.data || [];
    },
    initialData: [],
  });

  const { data: leaderboardData } = useQuery({
    queryKey: ['dashboard', 'leaderboard', 'registry'],
    queryFn: async () => {
      const res = await leaderboardAPI.getGlobal(1, 10);
      if (res.data.success) {
        return res.data.entries.map((entry) => ({
          id: entry.id,
          username: entry.name || 'Unknown User',
          rank: entry.rank,
          status: entry.progressHours > 10 ? 'IN FOCUS' : 'IDLE',
          statusColor: entry.progressHours > 10 ? 'green' : 'grey',
          email: entry.email || 'N/A',
          focusHours: entry.progressHours || 0,
          castles: Math.floor(entry.coins / 1000),
          sessions: Math.floor(entry.progressHours * 2),
          ...entry
        }));
      }
      return [];
    },
    initialData: [],
  });

  const { data: treasureStatsData } = useQuery({
    queryKey: ['dashboard', 'treasure', 'stats'],
    queryFn: async () => {
      const res = await treasureChestsAPI.getStats();
      return res.data.stats || res.data;
    },
  });

  const loading = statsLoading;
  const stats = statsData;
  const commanders = leaderboardData;
  const treasureStats = treasureStatsData;


  if (loading) {
    return <div className="dashboard-loading">Loading dashboard...</div>;
  }

  const statCards = [
    {
      title: 'Total Users',
      value: stats?.totalUsers || 1250,
      icon: 'people',
      color: '#3b82f6',
    },
    {
      title: 'Active Users',
      value: stats?.activeUsers || 342,
      icon: 'check_circle',
      color: '#10b981',
    },
    {
      title: 'Focus Sessions',
      value: stats?.totalFocusSessions || 8567,
      icon: 'timer',
      color: '#f59e0b',
    },
    {
      title: 'Total Focus Hours',
      value: stats?.totalFocusHours?.toFixed(1) || 2845.5,
      icon: 'access_time',
      color: '#8b5cf6',
    },
    {
      title: 'Castles Built',
      value: stats?.totalCastles || 890,
      icon: 'domain',
      color: '#ec4899',
    },
    {
      title: 'Treasure Chests',
      value: stats?.totalTreasureChests || 2340,
      icon: 'inventory_2',
      color: '#06b6d4',
    },
  ];

  // Live Commander Data
  const commanderData = commanders.length > 0 ? commanders : [];

  const handleViewProfile = (commander) => {
    setSelectedCommander(commander);
    setProfileModalOpen(true);
  };

  return (
    <div className="dashboard">
      {/* Main Stats Section with Castle Background */}
      <div className="castle-stats-section">
        <div className="castle-background">
          <img
            src={castleBackgroundImage}
            alt="Fantasy Castle"
            className="castle-bg-image"
          />
          <div className="castle-overlay"></div>
        </div>

        <div className="stats-cards-container">
          <div className="frosted-stat-card featured-stat">
            <div className="stat-icon-wrapper">
              <span className="material-icons">people</span>
            </div>
            <div className="stat-number">{(stats?.totalUsers || 2345).toLocaleString()}</div>
            <div className="stat-label">TOTAL COMMANDERS</div>
            <div className="stat-title">GLOBAL KINGDOM</div>
          </div>

          <div className="frosted-stat-card featured-stat">
            <div className="stat-icon-wrapper">
              <span className="material-icons">access_time</span>
            </div>
            <div className="stat-number">{((stats?.totalFocusHours || 0) * 60).toLocaleString()}</div>
            <div className="stat-label">TOTAL STUDY MINUTES</div>
          </div>
        </div>
      </div>

      {/* Three Panel Layout */}
      <div className="dashboard-panels">
        {/* Left Sidebar Panel - Stat Cards */}
        <div className="left-sidebar-panel">
          <div className="sidebar-stats">
            {statCards.map((stat, index) => (
              <div key={index} className="sidebar-stat-item">
                <div className="sidebar-stat-icon">
                  <span className="material-icons">{stat.icon}</span>
                </div>
                <div className="sidebar-stat-content">
                  <div className="sidebar-stat-value">{stat.value.toLocaleString()}</div>
                  <div className="sidebar-stat-title">{stat.title}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Middle Panel - Commander Registry */}
        <div className="middle-panel">
          <h2 className="panel-title">COMMANDER REGISTRY</h2>
          <div className="registry-table">
            <table>
              <thead>
                <tr>
                  <th>Username</th>
                  <th>Rank</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {commanderData.map((user) => (
                  <tr key={user.id}>
                    <td className="username-cell">{user.username}</td>
                    <td className="rank-cell">{user.rank}</td>
                    <td className="status-cell">
                      <span className={`status-indicator ${user.statusColor}`}></span>
                      <span>{user.status}</span>
                    </td>
                    <td className="actions-cell">
                      <button
                        className="view-profile-btn"
                        onClick={() => handleViewProfile(user)}
                      >
                        View Profile
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="registry-footer">
            <div className="total-users-info">
              <span className="info-label">TOTAL USERS IN KINGDOM:</span>
              <span className="info-value">{stats?.totalUsers || 0}</span>
            </div>
            <button
              className="view-all-users-btn"
              onClick={() => navigate('/users')}
            >
              VIEW ALL USERS
            </button>
          </div>
        </div>

        {/* Right Panel - The Treasury */}
        <div className="right-panel">
          <h2 className="panel-title">THE TREASURY</h2>
          <div className="treasury-content">
            <div className="treasure-chest-image">
              <img
                src={treasureChestImage}
                alt="Treasure Chest"
              />
            </div>

            <div className="treasure-config">
              <h3 className="config-title">CHEST CONFIGURATION</h3>

              <div className="config-item">
                <label>Unlock Minutes</label>
                <div className="config-input-group">
                  <input
                    type="number"
                    value={chestSettings.CHEST_UNLOCK_MINUTES}
                    onChange={(e) => handleSettingChange('CHEST_UNLOCK_MINUTES', e.target.value)}
                  />
                  <button onClick={() => saveSetting('CHEST_UNLOCK_MINUTES')}>SET</button>
                </div>
              </div>

              <div className="config-item">
                <label>Reward Coins</label>
                <div className="config-input-group">
                  <input
                    type="number"
                    value={chestSettings.CHEST_REWARD_COINS}
                    onChange={(e) => handleSettingChange('CHEST_REWARD_COINS', e.target.value)}
                  />
                  <button onClick={() => saveSetting('CHEST_REWARD_COINS')}>SET</button>
                </div>
              </div>

              <div className="config-item">
                <label>Reward Wood</label>
                <div className="config-input-group">
                  <input
                    type="number"
                    value={chestSettings.CHEST_REWARD_WOOD}
                    onChange={(e) => handleSettingChange('CHEST_REWARD_WOOD', e.target.value)}
                  />
                  <button onClick={() => saveSetting('CHEST_REWARD_WOOD')}>SET</button>
                </div>
              </div>

              <div className="config-item">
                <label>Reward Stone</label>
                <div className="config-input-group">
                  <input
                    type="number"
                    value={chestSettings.CHEST_REWARD_STONE}
                    onChange={(e) => handleSettingChange('CHEST_REWARD_STONE', e.target.value)}
                  />
                  <button onClick={() => saveSetting('CHEST_REWARD_STONE')}>SET</button>
                </div>
              </div>
            </div>

            <div className="treasury-stats-mini">
              <p>Total Chests: {treasureStats?.total || 0}</p>
              <p>Unlocked: {treasureStats?.unlocked || 0}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Commander Profile Modal */}
      <Modal
        isOpen={profileModalOpen}
        onClose={() => {
          setProfileModalOpen(false);
          setSelectedCommander(null);
        }}
        title="Commander Profile"
        size="medium"
      >
        {selectedCommander && (
          <div className="user-details">
            <div className="detail-row">
              <span className="detail-label">Username:</span>
              <span className="detail-value">{selectedCommander.username}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Rank:</span>
              <span className="detail-value">#{selectedCommander.rank}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Status:</span>
              <span className="detail-value">
                <span className={`status-indicator ${selectedCommander.statusColor}`}></span>
                {selectedCommander.status}
              </span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Email:</span>
              <span className="detail-value">{selectedCommander.email || 'N/A'}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Focus Hours:</span>
              <span className="detail-value">{selectedCommander.focusHours || 0} hours</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Castles Built:</span>
              <span className="detail-value">{selectedCommander.castles || 0}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Total Sessions:</span>
              <span className="detail-value">{selectedCommander.sessions || 0}</span>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default Dashboard;

