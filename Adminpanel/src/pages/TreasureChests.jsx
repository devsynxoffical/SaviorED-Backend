import { useState, useEffect } from 'react';
import { treasureChestsAPI } from '../services/api';
import DataTable from '../components/DataTable';
import './TreasureChests.css';

const TreasureChests = () => {
  const [chests, setChests] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    loadChests();
  }, [page]);

  const loadChests = async () => {
    try {
      setLoading(true);
      const response = await treasureChestsAPI.getAll(page, 20);
      if (response.data.success) {
        setChests(response.data.chests);
        setTotalPages(response.data.pagination?.pages || 1);
      }
    } catch (error) {
      console.error('Error loading chests:', error);
      setChests([]);
      setTotalPages(1);
    } finally {
      setLoading(false);
    }
  };

  const columns = [
    { key: 'id', label: 'Chest ID' },
    { key: 'userId', label: 'User ID' },
    {
      key: 'progressPercentage',
      label: 'Progress',
      render: (value) => (
        <div className="progress-bar-container">
          <div className="progress-bar" style={{ width: `${value}%` }}></div>
          <span className="progress-text">{value.toFixed(1)}%</span>
        </div>
      ),
    },
    {
      key: 'isUnlocked',
      label: 'Status',
      render: (value, row) => (
        <div className="chest-status">
          <span className={`status-badge ${value ? 'unlocked' : 'locked'}`}>
            {value ? '🔓 Unlocked' : '🔒 Locked'}
          </span>
          {row.isClaimed && (
            <span className="status-badge claimed">✓ Claimed</span>
          )}
        </div>
      ),
    },
    {
      key: 'rewards',
      label: 'Rewards',
      render: (value) => (
        <div className="rewards-list">
          {value?.map((reward) => (
            <span
              key={reward.id}
              className="reward-badge"
              style={{ backgroundColor: `${reward.colorHex}20`, color: reward.colorHex }}
            >
              {reward.title}
            </span>
          ))}
        </div>
      ),
    },
    {
      key: 'unlockedAt',
      label: 'Unlocked At',
      render: (value) => (value ? new Date(value).toLocaleString() : '-'),
    },
  ];

  return (
    <div className="treasure-chests-page">
      <div className="page-header">
        <h2>Treasure Chests</h2>
      </div>

      <DataTable
        columns={columns}
        data={chests}
        loading={loading}
        actions={(row) => (
          <>
            <button className="btn-view" onClick={() => alert(`View chest ${row.id}`)}>
              View
            </button>
            <button className="btn-edit" onClick={() => alert(`Edit chest ${row.id}`)}>
              Edit
            </button>
          </>
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

export default TreasureChests;

