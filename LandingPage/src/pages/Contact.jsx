import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Mail, MessageSquare, Send, MapPin } from 'lucide-react';

const Contact = () => {
    const [formState, setFormState] = useState({
        name: '',
        email: '',
        subject: '',
        message: ''
    });

    const handleSubmit = (e) => {
        e.preventDefault();
        console.log('Form submitted:', formState);
        alert('Thank you for reaching out! We will get back to you soon.');
    };

    return (
        <div className="contact-page pt-32 pb-20">
            <div className="container">
                <motion.div
                    className="section-header text-center mb-16"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                >
                    <h1 className="section-title gradient-text">Contact Support</h1>
                    <p className="section-subtitle">Have questions or need help with SaviorED? Our team is here to support your journey.</p>
                </motion.div>

                <div className="contact-grid">
                    <motion.div
                        className="contact-info"
                        initial={{ opacity: 0, x: -30 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.2 }}
                    >
                        <div className="info-card glass mb-6">
                            <Mail className="text-accent mb-4" size={32} />
                            <h3>Email Us</h3>
                            <p>For general inquiries and support</p>
                            <a href="mailto:info@saviored.com" className="text-accent font-bold">info@saviored.com</a>
                        </div>

                        <div className="info-card glass">
                            <MessageSquare className="text-accent mb-4" size={32} />
                            <h3>Live Chat</h3>
                            <p>Our support team is available Mon-Fri, 9am - 5pm EST.</p>
                            <button className="text-accent font-bold mt-2">Open Chat</button>
                        </div>
                    </motion.div>

                    <motion.div
                        className="contact-form-container glass"
                        initial={{ opacity: 0, x: 30 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.4 }}
                    >
                        <form onSubmit={handleSubmit} className="contact-form">
                            <div className="form-group mb-4">
                                <label>Full Name</label>
                                <input
                                    type="text"
                                    placeholder="John Doe"
                                    value={formState.name}
                                    onChange={(e) => setFormState({ ...formState, name: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="form-group mb-4">
                                <label>Email Address</label>
                                <input
                                    type="email"
                                    placeholder="john@example.com"
                                    value={formState.email}
                                    onChange={(e) => setFormState({ ...formState, email: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="form-group mb-4">
                                <label>Subject</label>
                                <input
                                    type="text"
                                    placeholder="How can we help?"
                                    value={formState.subject}
                                    onChange={(e) => setFormState({ ...formState, subject: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="form-group mb-6">
                                <label>Message</label>
                                <textarea
                                    rows="5"
                                    placeholder="Your message here..."
                                    value={formState.message}
                                    onChange={(e) => setFormState({ ...formState, message: e.target.value })}
                                    required
                                ></textarea>
                            </div>
                            <button type="submit" className="btn-primary w-full flex items-center justify-center gap-2">
                                <span>Send Message</span>
                                <Send size={18} />
                            </button>
                        </form>
                    </motion.div>
                </div>
            </div>

            <style dangerouslySetInnerHTML={{
                __html: `
        .contact-grid {
          display: grid;
          grid-template-columns: 1fr 2fr;
          gap: 3rem;
        }
        @media (max-width: 900px) {
          .contact-grid { grid-template-columns: 1fr; }
        }
        .info-card {
          padding: 2.5rem;
          text-align: center;
        }
        .info-card h3 {
          margin-bottom: 0.5rem;
          font-size: 1.3rem;
        }
        .info-card p {
          color: var(--color-text-muted);
          font-size: 0.9rem;
          margin-bottom: 0.5rem;
        }
        .contact-form-container {
          padding: 3rem;
        }
        .form-group label {
          display: block;
          margin-bottom: 0.5rem;
          font-size: 0.9rem;
          font-weight: 500;
          color: var(--color-accent);
          text-transform: uppercase;
          letter-spacing: 1px;
        }
        .form-group input, .form-group textarea {
          width: 100%;
          background: rgba(255, 255, 255, 0.05);
          border: 1px solid var(--color-border);
          border-radius: 8px;
          padding: 1rem;
          color: #fff;
          font-family: var(--font-body);
          transition: var(--transition);
        }
        .form-group input:focus, .form-group textarea:focus {
          outline: none;
          border-color: var(--color-accent);
          background: rgba(255, 255, 255, 0.1);
        }
        .pt-32 { padding-top: 8rem; }
        .pb-20 { padding-bottom: 5rem; }
        .w-full { width: 100%; }
        .justify-center { justify-content: center; }
      `}} />
        </div>
    );
};

export default Contact;
