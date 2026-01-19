import { useState, useEffect } from 'react';
import { focusSessionsAPI } from '../services/api';
import DataTable from '../components/DataTable';
import './FocusSessions.css';

const FocusSessions = () => {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  useEffect(() => {
    loadSessions();
  }, [page]);

  const loadSessions = async () => {
    try {
      setLoading(true);
      const response = await focusSessionsAPI.getAll(page, 20);
      if (response.data.success) {
        setSessions(response.data.sessions);
        setTotalPages(response.data.pagination?.pages || 1);
      }
    } catch (error) {
      console.error('Error loading sessions:', error);
      setSessions([]);
      setTotalPages(1);
    } finally {
      setLoading(false);
    }
  };

  const formatDuration = (seconds) => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return `${hours}h ${minutes}m`;
  };

  const columns = [
    { key: 'id', label: 'Session ID' },
    { key: 'userId', label: 'User ID' },
    {
      key: 'durationMinutes',
      label: 'Duration',
      render: (value, row) => formatDuration(row.totalSeconds),
    },
    {
      key: 'isCompleted',
      label: 'Status',
      render: (value) => (
        <span className={`status-badge ${value ? 'completed' : 'incomplete'}`}>
          {value ? 'Completed' : 'Incomplete'}
        </span>
      ),
    },
    {
      key: 'earnedCoins',
      label: 'Rewards',
      render: (value, row) => (
        <div className="rewards-cell">
          <span>💰 {value || 0}</span>
          <span>🪨 {row.earnedStones || 0}</span>
          <span>🪵 {row.earnedWood || 0}</span>
        </div>
      ),
    },
    {
      key: 'startTime',
      label: 'Start Time',
      render: (value) => (value ? new Date(value).toLocaleString() : '-'),
    },
  ];

  return (
    <div className="focus-sessions-page">
      <div className="page-header">
        <h2>Focus Sessions</h2>
      </div>

      <DataTable
        columns={columns}
        data={sessions}
        loading={loading}
        actions={(row) => (
          <>
            <button className="btn-view" onClick={() => alert(`View session ${row.id}`)}>
              View
            </button>
            <button className="btn-delete" onClick={() => alert(`Delete session ${row.id}`)}>
              Delete
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

export default FocusSessions;

