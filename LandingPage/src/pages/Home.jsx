import React from 'react';
import { motion } from 'framer-motion';
import { BookOpen, Trophy, Castle, Timer, Star, CheckCircle } from 'lucide-react';

const Home = () => {
    const features = [
        {
            icon: <Timer size={32} className="text-accent" />,
            title: "Focus Sessions",
            description: "Dedicated study timers designed to keep children engaged and minimize distractions."
        },
        {
            icon: <Trophy size={32} className="text-accent" />,
            title: "Earn Rewards",
            description: "Complete study goals to earn coins, stones, and wood to fuel your progress."
        },
        {
            icon: <Castle size={32} className="text-accent" />,
            title: "Build Your Castle",
            description: "Use earned rewards to construct and customize your very own virtual fortress."
        }
    ];

    const fadeIn = {
        initial: { opacity: 0, y: 30 },
        animate: { opacity: 1, y: 0 },
        transition: { duration: 0.8 }
    };

    return (
        <div className="home-page">
            {/* Hero Section */}
            <section className="hero-section">
                <div className="container hero-grid">
                    <motion.div
                        className="hero-content"
                        initial={{ opacity: 0, x: -50 }}
                        whileInView={{ opacity: 1, x: 0 }}
                        viewport={{ once: true }}
                        transition={{ duration: 1 }}
                    >
                        <span className="badge">The Future of Education</span>
                        <h1 className="hero-title">Study Hard, <br /><span className="gradient-text">Build Your Legacy</span></h1>
                        <p className="hero-subtitle">
                            SaviorED transforms focus time into an epic adventure. Help your children fall in love with learning by rewarding their dedication with the resources to build their own majestic castle.
                        </p>
                        <div className="hero-btns">
                            <button className="btn-primary">Start Your Journey</button>
                            <button className="btn-secondary">Learn More</button>
                        </div>
                    </motion.div>

                    <motion.div
                        className="hero-image-container"
                        initial={{ opacity: 0, scale: 0.8 }}
                        whileInView={{ opacity: 1, scale: 1 }}
                        viewport={{ once: true }}
                        transition={{ duration: 1 }}
                    >
                        <div className="castle-preview glass">
                            {/* This will be replaced by a generated image */}
                            <img src="/castle_hero.png" alt="Epic Castle" className="hero-img" />
                            <div className="floating-stat glass">
                                <Star color="#d4af37" fill="#d4af37" size={20} />
                                <span>Level 12 Fortress</span>
                            </div>
                        </div>
                    </motion.div>
                </div>
            </section>

            {/* Objective Section */}
            <section className="objective-section section-padding" id="features">
                <div className="container">
                    <div className="section-header text-center">
                        <h2 className="section-title">The SaviorED Mission</h2>
                        <p className="section-subtitle">Our primary goal is to help children find joy in learning through gamified achievement.</p>
                    </div>

                    <div className="features-grid">
                        {features.map((f, idx) => (
                            <motion.div
                                key={idx}
                                className="feature-card glass"
                                whileHover={{ y: -10 }}
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                transition={{ delay: idx * 0.2 }}
                            >
                                <div className="feature-icon">{f.icon}</div>
                                <h3>{f.title}</h3>
                                <p>{f.description}</p>
                            </motion.div>
                        ))}
                    </div>
                </div>
            </section>

            {/* How it Works */}
            <section className="how-it-works glass">
                <div className="container">
                    <div className="how-grid">
                        <div className="how-image">
                            <img src="/study_reward.png" alt="Studying for rewards" className="rounded-img" />
                        </div>
                        <div className="how-content">
                            <h2 className="section-title">Gamified Growth</h2>
                            <div className="step">
                                <div className="step-num">01</div>
                                <div>
                                    <h4>Set Study Goals</h4>
                                    <p>Define what you want to achieve today in your focus session.</p>
                                </div>
                            </div>
                            <div className="step">
                                <div className="step-num">02</div>
                                <div>
                                    <h4>Deep Focus Time</h4>
                                    <p>Study without distractions. Our app tracks your progress in real-time.</p>
                                </div>
                            </div>
                            <div className="step">
                                <div className="step-num">03</div>
                                <div>
                                    <h4>Earn & Expand</h4>
                                    <p>Receive resources based on your study time. Use them to upgrade your castle!</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* CTA Section */}
            <section className="cta-section section-padding">
                <div className="container">
                    <div className="cta-card glass text-center">
                        <h2 className="mb-4">Ready to Build Your Future?</h2>
                        <p className="mb-6">Join thousands of students who are turning their study time into a rewarding experience.</p>
                        <button className="btn-primary">Get Started Now</button>
                    </div>
                </div>
            </section>

            <style dangerouslySetInnerHTML={{
                __html: `
        .hero-section {
          padding: 160px 0 100px;
          position: relative;
          background: radial-gradient(circle at top right, rgba(26, 71, 42, 0.3) 0%, transparent 70%);
        }
        .hero-grid {
          display: grid;
          grid-template-columns: 1.2fr 1fr;
          gap: 4rem;
          align-items: center;
        }
        @media (max-width: 992px) {
          .hero-grid {
            grid-template-columns: 1fr;
            text-align: center;
          }
          .hero-btns {
            justify-content: center;
          }
        }
        .badge {
          background: rgba(212, 175, 55, 0.1);
          color: var(--color-accent);
          padding: 0.5rem 1rem;
          border-radius: 50px;
          font-size: 0.8rem;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 2px;
          border: 1px solid var(--color-border);
          display: inline-block;
          margin-bottom: 2rem;
        }
        .hero-title {
          font-size: clamp(2.5rem, 5vw, 4.5rem);
          line-height: 1.1;
          margin-bottom: 1.5rem;
        }
        .hero-subtitle {
          font-size: 1.2rem;
          color: var(--color-text-muted);
          margin-bottom: 2.5rem;
          max-width: 600px;
        }
        .hero-btns {
          display: flex;
          gap: 1.5rem;
        }
        .btn-secondary {
          border: 1px solid var(--color-border);
          color: var(--color-text);
          padding: 0.8rem 2rem;
          border-radius: 8px;
          font-weight: 600;
        }
        .btn-secondary:hover {
          background: rgba(255, 255, 255, 0.05);
        }
        .hero-image-container {
          position: relative;
        }
        .castle-preview {
          padding: 1rem;
          overflow: hidden;
          box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }
        .hero-img {
          width: 100%;
          border-radius: 8px;
          display: block;
          aspect-ratio: 4/5;
          object-fit: cover;
          background: #122312; /* Fallback */
        }
        .floating-stat {
          position: absolute;
          bottom: 2rem;
          right: -1rem;
          padding: 1rem 1.5rem;
          display: flex;
          align-items: center;
          gap: 0.8rem;
          animation: float 4s ease-in-out infinite;
        }
        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-10px); }
        }
        .section-header {
          margin-bottom: 4rem;
        }
        .section-title {
          font-size: 2.5rem;
          margin-bottom: 1rem;
        }
        .section-subtitle {
          color: var(--color-text-muted);
          max-width: 700px;
          margin: 0 auto;
        }
        .features-grid {
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 2rem;
        }
        .feature-card {
          padding: 3rem 2rem;
          text-align: center;
        }
        .feature-icon {
          margin-bottom: 1.5rem;
          display: inline-block;
        }
        .feature-card h3 {
          margin-bottom: 1rem;
          color: var(--color-accent);
        }
        .how-it-works {
          margin: 100px auto;
          padding: 80px 0;
          border-radius: 0;
          border-left: none;
          border-right: none;
        }
        .how-grid {
          display: grid;
          grid-template-columns: 1fr 1.2fr;
          gap: 6rem;
          align-items: center;
        }
        @media (max-width: 992px) {
          .how-grid { grid-template-columns: 1fr; gap: 3rem; }
        }
        .rounded-img {
          width: 100%;
          border-radius: 20px;
          border: 1px solid var(--color-border);
        }
        .step {
          display: flex;
          gap: 2rem;
          margin-bottom: 2.5rem;
        }
        .step-num {
          font-family: var(--font-heading);
          font-size: 2rem;
          color: var(--color-accent);
          opacity: 0.5;
        }
        .step h4 {
          font-size: 1.3rem;
          margin-bottom: 0.5rem;
        }
        .cta-card {
          padding: 60px;
          background: linear-gradient(135deg, rgba(26, 71, 42, 0.4) 0%, rgba(212, 175, 55, 0.1) 100%);
        }
        .mb-6 { margin-bottom: 1.5rem; }
      `}} />
        </div>
    );
};

export default Home;
