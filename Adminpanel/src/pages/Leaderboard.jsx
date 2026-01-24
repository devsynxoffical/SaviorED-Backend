import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { leaderboardAPI } from '../services/api';
import DataTable from '../components/DataTable';
import Modal from '../components/Modal';
import './Leaderboard.css';

const Leaderboard = () => {
  // Page State
  const [page, setPage] = useState(1);
  const [type, setType] = useState('global');

  // UI State
  const [profileModalOpen, setProfileModalOpen] = useState(false);
  const [selectedEntry, setSelectedEntry] = useState(null);

  // React Query for data fetching
  const { data, isLoading, refetch } = useQuery({
    queryKey: ['leaderboard', type, page],
    queryFn: async () => {
      const response = type === 'global'
        ? await leaderboardAPI.getGlobal(page, 20)
        : await leaderboardAPI.getSchool(page, 20);
      return response.data;
    },
    keepPreviousData: true,
  });

  const entries = data?.entries || [];
  const totalPages = data?.pagination?.pages || 1;
  const loading = isLoading;

  const handleRefresh = () => {
    refetch();
  };

  const columns = [
    { key: 'rank', label: 'Rank' },
    {
      key: 'name',
      label: 'User',
      render: (value, row) => (
        <div className="leaderboard-user">
          <span className="rank-badge rank-${row.rank <= 3 ? row.rank : 'other'}">
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
            onClick={handleRefresh}
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
          <button
            className="btn-view"
            onClick={() => {
              setSelectedEntry(row);
              setProfileModalOpen(true);
            }}
          >
            View Profile
          </button>
        )}
      />

      {/* Profile Modal */}
      <Modal
        isOpen={profileModalOpen}
        onClose={() => {
          setProfileModalOpen(false);
          setSelectedEntry(null);
        }}
        title="User Profile"
        size="medium"
      >
        {selectedEntry && (
          <div className="user-details">
            <div className="detail-row">
              <span className="detail-label">User ID:</span>
              <span className="detail-value">{selectedEntry.userId}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Name:</span>
              <span className="detail-value">{selectedEntry.name || 'N/A'}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Rank:</span>
              <span className="detail-value">#{selectedEntry.rank}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Level:</span>
              <span className="detail-value">{selectedEntry.level || 'N/A'}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Coins:</span>
              <span className="detail-value">💰 {selectedEntry.coins?.toLocaleString() || 0}</span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Progress:</span>
              <span className="detail-value">
                {selectedEntry.progressHours?.toFixed(1) || 0}h / {selectedEntry.progressMaxHours || 100}h
              </span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Progress Percentage:</span>
              <span className="detail-value">
                {((selectedEntry.progressHours / selectedEntry.progressMaxHours) * 100 || 0).toFixed(1)}%
              </span>
            </div>
            <div className="detail-row">
              <span className="detail-label">Last Updated:</span>
              <span className="detail-value">
                {selectedEntry.updatedAt ? new Date(selectedEntry.updatedAt).toLocaleString() : 'N/A'}
              </span>
            </div>
          </div>
        )}
      </Modal>

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

