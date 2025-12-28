defmodule MyhpWeb.PhoenixLive do
  use MyhpWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Rise from the Ashes")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="phoenix-container">
      <div class="stars"></div>
      <div class="particles">
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
        <div class="particle"></div>
      </div>

      <div class="phoenix-wrapper">
        <div class="glow-effect"></div>
        <div class="phoenix-logo">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 71 48" class="phoenix-svg">
            <defs>
              <linearGradient id="fireGradient" x1="0%" y1="100%" x2="0%" y2="0%">
                <stop offset="0%" style="stop-color:#ff4500;stop-opacity:1">
                  <animate attributeName="stop-color" values="#ff4500;#ff6b35;#ff4500" dur="2s" repeatCount="indefinite" />
                </stop>
                <stop offset="50%" style="stop-color:#ff6b35;stop-opacity:1">
                  <animate attributeName="stop-color" values="#ff6b35;#ffa500;#ff6b35" dur="1.5s" repeatCount="indefinite" />
                </stop>
                <stop offset="100%" style="stop-color:#ffd700;stop-opacity:1">
                  <animate attributeName="stop-color" values="#ffd700;#ffff00;#ffd700" dur="1s" repeatCount="indefinite" />
                </stop>
              </linearGradient>

              <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
                <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
                <feMerge>
                  <feMergeNode in="coloredBlur"/>
                  <feMergeNode in="SourceGraphic"/>
                </feMerge>
              </filter>

              <filter id="fireGlow" x="-100%" y="-100%" width="300%" height="300%">
                <feGaussianBlur stdDeviation="8" result="blur1"/>
                <feGaussianBlur stdDeviation="4" result="blur2"/>
                <feMerge>
                  <feMergeNode in="blur1"/>
                  <feMergeNode in="blur2"/>
                  <feMergeNode in="SourceGraphic"/>
                </feMerge>
              </filter>
            </defs>

            <path
              d="m26.371 33.477-.552-.1c-3.92-.729-6.397-3.1-7.57-6.829-.733-2.324.597-4.035 3.035-4.148 1.995-.092 3.362 1.055 4.57 2.39 1.557 1.72 2.984 3.558 4.514 5.305 2.202 2.515 4.797 4.134 8.347 3.634 3.183-.448 5.958-1.725 8.371-3.828.363-.316.761-.592 1.144-.886l-.241-.284c-2.027.63-4.093.841-6.205.735-3.195-.16-6.24-.828-8.964-2.582-2.486-1.601-4.319-3.746-5.19-6.611-.704-2.315.736-3.934 3.135-3.6.948.133 1.746.56 2.463 1.165.583.493 1.143 1.015 1.738 1.493 2.8 2.25 6.712 2.375 10.265-.068-5.842-.026-9.817-3.24-13.308-7.313-1.366-1.594-2.7-3.216-4.095-4.785-2.698-3.036-5.692-5.71-9.79-6.623C12.8-.623 7.745.14 2.893 2.361 1.926 2.804.997 3.319 0 4.149c.494 0 .763.006 1.032 0 2.446-.064 4.28 1.023 5.602 3.024.962 1.457 1.415 3.104 1.761 4.798.513 2.515.247 5.078.544 7.605.761 6.494 4.08 11.026 10.26 13.346 2.267.852 4.591 1.135 7.172.555ZM10.751 3.852c-.976.246-1.756-.148-2.56-.962 1.377-.343 2.592-.476 3.897-.528-.107.848-.607 1.306-1.336 1.49Zm32.002 37.924c-.085-.626-.62-.901-1.04-1.228-1.857-1.446-4.03-1.958-6.333-2-1.375-.026-2.735-.128-4.031-.61-.595-.22-1.26-.505-1.244-1.272.015-.78.693-1 1.31-1.184.505-.15 1.026-.247 1.6-.382-1.46-.936-2.886-1.065-4.787-.3-2.993 1.202-5.943 1.06-8.926-.017-1.684-.608-3.179-1.563-4.735-2.408l-.077.057c1.29 2.115 3.034 3.817 5.004 5.271 3.793 2.8 7.936 4.471 12.784 3.73A66.714 66.714 0 0 1 37 40.877c1.98-.16 3.866.398 5.753.899Zm-9.14-30.345c-.105-.076-.206-.266-.42-.069 1.745 2.36 3.985 4.098 6.683 5.193 4.354 1.767 8.773 2.07 13.293.51 3.51-1.21 6.033-.028 7.343 3.38.19-3.955-2.137-6.837-5.843-7.401-2.084-.318-4.01.373-5.962.94-5.434 1.575-10.485.798-15.094-2.553Zm27.085 15.425c.708.059 1.416.123 2.124.185-1.6-1.405-3.55-1.517-5.523-1.404-3.003.17-5.167 1.903-7.14 3.972-1.739 1.824-3.31 3.87-5.903 4.604.043.078.054.117.066.117.35.005.699.021 1.047.005 3.768-.17 7.317-.965 10.14-3.7.89-.86 1.685-1.817 2.544-2.71.716-.746 1.584-1.159 2.645-1.07Zm-8.753-4.67c-2.812.246-5.254 1.409-7.548 2.943-1.766 1.18-3.654 1.738-5.776 1.37-.374-.066-.75-.114-1.124-.17l-.013.156c.135.07.265.151.405.207.354.14.702.308 1.07.395 4.083.971 7.992.474 11.516-1.803 2.221-1.435 4.521-1.707 7.013-1.336.252.038.503.083.756.107.234.022.479.255.795.003-2.179-1.574-4.526-2.096-7.094-1.872Zm-10.049-9.544c1.475.051 2.943-.142 4.486-1.059-.452.04-.643.04-.827.076-2.126.424-4.033-.04-5.733-1.383-.623-.493-1.257-.974-1.889-1.457-2.503-1.914-5.374-2.555-8.514-2.5.05.154.054.26.108.315 3.417 3.455 7.371 5.836 12.369 6.008Zm24.727 17.731c-2.114-2.097-4.952-2.367-7.578-.537 1.738.078 3.043.632 4.101 1.728a13 13 0 0 0 1.182 1.106c1.6 1.29 4.311 1.352 5.896.155-1.861-.726-1.861-.726-3.601-2.452Zm-21.058 16.06c-1.858-3.46-4.981-4.24-8.59-4.008a9.667 9.667 0 0 1 2.977 1.39c.84.586 1.547 1.311 2.243 2.055 1.38 1.473 3.534 2.376 4.962 2.07-.656-.412-1.238-.848-1.592-1.507Z"
              fill="url(#fireGradient)"
              filter="url(#fireGlow)"
              class="phoenix-path"
            />
          </svg>
        </div>
        <div class="flame-ring"></div>
      </div>

      <div class="phoenix-text">
        <h1 class="phoenix-title">Phoenix Framework</h1>
        <p class="phoenix-subtitle">Peace of mind from prototype to production</p>
        <a href="https://www.phoenixframework.org/" target="_blank" rel="noopener noreferrer" class="phoenix-link">
          Visit phoenixframework.org
        </a>
      </div>
    </div>

    <style>
      .phoenix-container {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        background: linear-gradient(135deg, #0a0a0a 0%, #1a0a0a 50%, #0a0505 100%);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        z-index: 50;
      }

      .stars {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-image:
          radial-gradient(2px 2px at 20px 30px, #fff, transparent),
          radial-gradient(2px 2px at 40px 70px, rgba(255,255,255,0.8), transparent),
          radial-gradient(1px 1px at 90px 40px, #fff, transparent),
          radial-gradient(2px 2px at 160px 120px, rgba(255,255,255,0.6), transparent),
          radial-gradient(1px 1px at 230px 80px, #fff, transparent),
          radial-gradient(2px 2px at 300px 150px, rgba(255,255,255,0.7), transparent),
          radial-gradient(1px 1px at 370px 60px, #fff, transparent),
          radial-gradient(2px 2px at 450px 200px, rgba(255,255,255,0.5), transparent);
        background-repeat: repeat;
        background-size: 500px 300px;
        animation: twinkle 8s ease-in-out infinite;
        opacity: 0.6;
      }

      @keyframes twinkle {
        0%, 100% { opacity: 0.6; }
        50% { opacity: 0.3; }
      }

      .particles {
        position: absolute;
        width: 100%;
        height: 100%;
        overflow: hidden;
      }

      .particle {
        position: absolute;
        width: 8px;
        height: 8px;
        background: radial-gradient(circle, #ff6b35 0%, #ff4500 50%, transparent 100%);
        border-radius: 50%;
        animation: float-up 4s ease-in infinite;
        opacity: 0;
      }

      .particle:nth-child(1) { left: 45%; animation-delay: 0s; }
      .particle:nth-child(2) { left: 48%; animation-delay: 0.3s; }
      .particle:nth-child(3) { left: 51%; animation-delay: 0.6s; }
      .particle:nth-child(4) { left: 54%; animation-delay: 0.9s; }
      .particle:nth-child(5) { left: 47%; animation-delay: 1.2s; }
      .particle:nth-child(6) { left: 50%; animation-delay: 1.5s; }
      .particle:nth-child(7) { left: 53%; animation-delay: 1.8s; }
      .particle:nth-child(8) { left: 46%; animation-delay: 2.1s; }
      .particle:nth-child(9) { left: 52%; animation-delay: 2.4s; }
      .particle:nth-child(10) { left: 49%; animation-delay: 2.7s; }
      .particle:nth-child(11) { left: 44%; animation-delay: 3.0s; }
      .particle:nth-child(12) { left: 55%; animation-delay: 3.3s; }

      @keyframes float-up {
        0% {
          bottom: 35%;
          opacity: 0;
          transform: translateX(0) scale(1);
        }
        10% {
          opacity: 1;
        }
        90% {
          opacity: 0.8;
        }
        100% {
          bottom: 85%;
          opacity: 0;
          transform: translateX(calc((var(--random, 0) - 0.5) * 100px)) scale(0.3);
        }
      }

      .phoenix-wrapper {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .glow-effect {
        position: absolute;
        width: 350px;
        height: 350px;
        background: radial-gradient(circle, rgba(255,69,0,0.4) 0%, rgba(255,107,53,0.2) 40%, transparent 70%);
        border-radius: 50%;
        animation: pulse-glow 3s ease-in-out infinite;
      }

      @keyframes pulse-glow {
        0%, 100% {
          transform: scale(1);
          opacity: 0.8;
        }
        50% {
          transform: scale(1.15);
          opacity: 1;
        }
      }

      .flame-ring {
        position: absolute;
        width: 280px;
        height: 280px;
        border: 3px solid transparent;
        border-radius: 50%;
        background: linear-gradient(#0a0a0a, #0a0a0a) padding-box,
                    linear-gradient(45deg, #ff4500, #ffa500, #ff6b35, #ff4500) border-box;
        animation: rotate-ring 8s linear infinite;
        opacity: 0.6;
      }

      @keyframes rotate-ring {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
      }

      .phoenix-logo {
        position: relative;
        z-index: 10;
        animation: float 4s ease-in-out infinite, breathe 2s ease-in-out infinite;
      }

      @keyframes float {
        0%, 100% { transform: translateY(0); }
        50% { transform: translateY(-15px); }
      }

      @keyframes breathe {
        0%, 100% { filter: drop-shadow(0 0 20px rgba(255,69,0,0.8)); }
        50% { filter: drop-shadow(0 0 40px rgba(255,165,0,1)); }
      }

      .phoenix-svg {
        width: 200px;
        height: auto;
      }

      .phoenix-path {
        animation: flicker 0.1s ease-in-out infinite alternate;
      }

      @keyframes flicker {
        0% { opacity: 0.95; }
        100% { opacity: 1; }
      }

      .phoenix-text {
        margin-top: 60px;
        text-align: center;
        z-index: 10;
      }

      .phoenix-title {
        font-size: 2.5rem;
        font-weight: 700;
        background: linear-gradient(90deg, #ff4500, #ffa500, #ffd700);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        text-shadow: 0 0 30px rgba(255,69,0,0.5);
        margin-bottom: 0.5rem;
        animation: text-glow 2s ease-in-out infinite;
      }

      @keyframes text-glow {
        0%, 100% { filter: brightness(1); }
        50% { filter: brightness(1.2); }
      }

      .phoenix-subtitle {
        font-size: 1.1rem;
        color: rgba(255,165,0,0.8);
        margin-bottom: 1.5rem;
        letter-spacing: 0.05em;
      }

      .phoenix-link {
        display: inline-block;
        padding: 0.75rem 1.5rem;
        background: linear-gradient(135deg, rgba(255,69,0,0.2) 0%, rgba(255,107,53,0.1) 100%);
        border: 1px solid rgba(255,107,53,0.4);
        border-radius: 8px;
        color: #ffa500;
        text-decoration: none;
        font-weight: 500;
        transition: all 0.3s ease;
      }

      .phoenix-link:hover {
        background: linear-gradient(135deg, rgba(255,69,0,0.4) 0%, rgba(255,107,53,0.2) 100%);
        border-color: rgba(255,165,0,0.6);
        transform: translateY(-2px);
        box-shadow: 0 10px 30px rgba(255,69,0,0.3);
      }

      @media (max-width: 640px) {
        .phoenix-svg {
          width: 150px;
        }

        .glow-effect {
          width: 250px;
          height: 250px;
        }

        .flame-ring {
          width: 200px;
          height: 200px;
        }

        .phoenix-title {
          font-size: 1.75rem;
        }

        .phoenix-subtitle {
          font-size: 0.95rem;
          padding: 0 1rem;
        }
      }
    </style>
    """
  end
end
