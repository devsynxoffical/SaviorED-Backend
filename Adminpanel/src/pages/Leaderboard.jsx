import { useState, useEffect } from 'react';
import { leaderboardAPI } from '../services/api';
import DataTable from '../components/DataTable';
import ImageWithFallback from '../components/ImageWithFallback';
import './Leaderboard.css';

const Leaderboard = () => {
  const [entries, setEntries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [type, setType] = useState('global');

  useEffect(() => {
    loadLeaderboard();
  }, [page, type]);

  const loadLeaderboard = async () => {
    try {
      setLoading(true);
      const response = type === 'global' 
        ? await leaderboardAPI.getGlobal(page, 20)
        : await leaderboardAPI.getSchool(page, 20);
      // Mock data for development
      const mockEntries = Array.from({ length: 20 }, (_, i) => ({
        id: `entry-${i + 1}`,
        userId: `user-${Math.floor(Math.random() * 50) + 1}`,
        name: `User ${i + 1}`,
        level: `Level ${Math.floor(Math.random() * 20) + 1}`,
        rank: (page - 1) * 20 + i + 1,
        coins: Math.floor(Math.random() * 5000),
        progressHours: Math.random() * 100,
        progressMaxHours: 100,
        avatar: null,
        updatedAt: new Date(Date.now() - Math.random() * 10000000000).toISOString(),
      }));
      setEntries(mockEntries);
      setTotalPages(5);
    } catch (error) {
      console.error('Error loading leaderboard:', error);
      const mockEntries = Array.from({ length: 20 }, (_, i) => ({
        id: `entry-${i + 1}`,
        userId: `user-${Math.floor(Math.random() * 50) + 1}`,
        name: `User ${i + 1}`,
        level: `Level ${Math.floor(Math.random() * 20) + 1}`,
        rank: (page - 1) * 20 + i + 1,
        coins: Math.floor(Math.random() * 5000),
        progressHours: Math.random() * 100,
        progressMaxHours: 100,
        avatar: null,
        updatedAt: new Date(Date.now() - Math.random() * 10000000000).toISOString(),
      }));
      setEntries(mockEntries);
      setTotalPages(5);
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { key: 'rank', label: 'Rank' },
    {
      key: 'name',
      label: 'User',
      render: (value, row) => (
        <div className="leaderboard-user">
          {row.avatar && (
            <ImageWithFallback
              src={row.avatar}
              alt={value || 'User'}
              className="leaderboard-avatar"
            />
          )}
          <span className={`rank-badge rank-${row.rank <= 3 ? row.rank : 'other'}`}>
            #{row.rank}
          </span>
          <span>{value}</span>
        </div>
      ),
    },
    { key: 'level', label: 'Level' },
    {
      key: 'coins',
      label: 'Coins',
      render: (value) => `💰 ${value?.toLocaleString() || 0}`,
    },
    {
      key: 'progressHours',
      label: 'Progress',
      render: (value, row) => (
        <div className="progress-cell">
          <span>{value?.toFixed(1) || 0}h / {row.progressMaxHours || 100}h</span>
        </div>
      ),
    },
  ];

  return (
    <div className="leaderboard-page">
      <div className="page-header">
        <h2>Leaderboard</h2>
        <div className="page-actions">
          <select
            value={type}
            onChange={(e) => setType(e.target.value)}
            className="type-select"
          >
            <option value="global">Global</option>
            <option value="school">School</option>
          </select>
          <button
            className="refresh-btn"
            onClick={loadLeaderboard}
          >
            Refresh
          </button>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={entries}
        loading={loading}
        actions={(row) => (
          <button className="btn-view" onClick={() => alert(`View user ${row.userId}`)}>
            View Profile
          </button>
        )}
      />

      <div className="pagination">
        <button
          onClick={() => setPage((p) => Math.max(1, p - 1))}
          disabled={page === 1}
        >
          Previous
        </button>
        <span>
          Page {page} of {totalPages}
        </span>
        <button
          onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
          disabled={page === totalPages}
        >
          Next
        </button>
      </div>
    </div>
  );
};

export default Leaderboard;

