import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/tool_widgets.dart';

class _DeployOption {
  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  final Color color;
  final String difficulty;
  final String cost;
  final List<(String, String?)> steps;
  final String? link;

  const _DeployOption({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.cost,
    required this.steps,
    this.link,
  });
}

const _options = [
  _DeployOption(
    id: 'cloud',
    name: 'n8n Cloud',
    tagline: 'Official hosted n8n - no server to manage',
    icon: Icons.cloud_rounded,
    color: Color(0xFFFF6D3F),
    difficulty: 'Easiest',
    cost: 'Paid, free trial',
    link: 'https://n8n.io/pricing/',
    steps: [
      ('Create an account at n8n.io and start the free trial.', null),
      ('Your instance URL looks like https://yourname.app.n8n.cloud', null),
      ('Create an API key (see "Connect this app" below).', null),
    ],
  ),
  _DeployOption(
    id: 'docker',
    name: 'Docker',
    tagline: 'One command on any Linux, Mac or Windows machine',
    icon: Icons.directions_boat_rounded,
    color: Color(0xFF2496ED),
    difficulty: 'Easy',
    cost: 'Free (self-hosted)',
    link: 'https://docs.n8n.io/hosting/installation/docker/',
    steps: [
      (
        'Create a volume so your data survives restarts:',
        'docker volume create n8n_data'
      ),
      (
        'Start n8n:',
        'docker run -d --name n8n --restart unless-stopped \\\n'
            '  -p 5678:5678 \\\n'
            '  -e GENERIC_TIMEZONE="Asia/Dhaka" \\\n'
            '  -e TZ="Asia/Dhaka" \\\n'
            '  -v n8n_data:/home/node/.n8n \\\n'
            '  docker.n8n.io/n8nio/n8n'
      ),
      ('Open http://<server-ip>:5678 and create the owner account.', null),
      (
        'Update later:',
        'docker pull docker.n8n.io/n8nio/n8n\n'
            'docker rm -f n8n   # then run the start command again'
      ),
    ],
  ),
  _DeployOption(
    id: 'compose',
    name: 'VPS + Docker Compose + HTTPS',
    tagline: 'Production setup with your own domain and free SSL',
    icon: Icons.dns_rounded,
    color: Color(0xFF00D4AA),
    difficulty: 'Medium',
    cost: 'VPS from ~\$5/month',
    link:
        'https://docs.n8n.io/hosting/installation/server-setups/docker-compose/',
    steps: [
      (
        'Point a DNS A record (e.g. n8n.example.com) to your VPS IP, then install Docker:',
        'curl -fsSL https://get.docker.com | sh'
      ),
      (
        'Create docker-compose.yml:',
        'services:\n'
            '  caddy:\n'
            '    image: caddy:2\n'
            '    restart: unless-stopped\n'
            '    ports: ["80:80", "443:443"]\n'
            '    command: caddy reverse-proxy --from n8n.example.com --to n8n:5678\n'
            '    volumes: [caddy_data:/data]\n'
            '  n8n:\n'
            '    image: docker.n8n.io/n8nio/n8n\n'
            '    restart: unless-stopped\n'
            '    environment:\n'
            '      - N8N_HOST=n8n.example.com\n'
            '      - N8N_PROTOCOL=https\n'
            '      - WEBHOOK_URL=https://n8n.example.com/\n'
            '      - GENERIC_TIMEZONE=Asia/Dhaka\n'
            '    volumes: [n8n_data:/home/node/.n8n]\n'
            'volumes:\n'
            '  n8n_data:\n'
            '  caddy_data:'
      ),
      ('Start everything:', 'docker compose up -d'),
      (
        'Open https://n8n.example.com - Caddy gets the SSL certificate automatically.',
        null
      ),
    ],
  ),
  _DeployOption(
    id: 'npm',
    name: 'npm (Node.js)',
    tagline: 'Run n8n directly with Node.js 20+',
    icon: Icons.terminal_rounded,
    color: Color(0xFF8BC34A),
    difficulty: 'Easy',
    cost: 'Free (self-hosted)',
    link: 'https://docs.n8n.io/hosting/installation/npm/',
    steps: [
      ('Try it without installing:', 'npx n8n'),
      ('Or install globally and start:', 'npm install -g n8n\nn8n start'),
      (
        'Keep it running in the background with pm2:',
        'npm install -g pm2\npm2 start n8n\npm2 save && pm2 startup'
      ),
    ],
  ),
  _DeployOption(
    id: 'paas',
    name: 'Railway / Render',
    tagline: 'One-click cloud templates with HTTPS',
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFFB36BFF),
    difficulty: 'Easy',
    cost: 'Usage based',
    link: 'https://railway.com/template/n8n',
    steps: [
      ('Open the n8n template on Railway (or Render) and click Deploy.', null),
      ('Add a volume / Postgres so workflows are not lost on redeploy.', null),
      ('Set WEBHOOK_URL to the public URL the platform gives you.', null),
    ],
  ),
];

class DeployGuideScreen extends StatefulWidget {
  const DeployGuideScreen({super.key});

  @override
  State<DeployGuideScreen> createState() => _DeployGuideScreenState();
}

class _DeployGuideScreenState extends State<DeployGuideScreen> {
  String _selected = 'docker';

  @override
  Widget build(BuildContext context) {
    final opt = _options.firstWhere((o) => o.id == _selected);
    return ToolPage(
      title: 'Deploy n8n',
      header: const ToolHeader(
        icon: Icons.rocket_launch_rounded,
        title: 'Run your own n8n server',
        subtitle: 'Pick a hosting option, follow the steps, then connect this '
            'app with an API key.',
      ),
      children: [
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final o = _options[i];
              final sel = o.id == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = o.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 128,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: sel
                        ? o.color.withValues(alpha: 0.16)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: sel ? o.color : o.color.withValues(alpha: 0.25),
                        width: sel ? 1.6 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(o.icon, color: o.color),
                      const Spacer(),
                      Text(o.name,
                          maxLines: 2,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12.5)),
                      const SizedBox(height: 2),
                      Text(o.difficulty,
                          style: TextStyle(fontSize: 11, color: o.color)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ToolCard(
          borderColor: opt.color.withValues(alpha: 0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(opt.icon, color: opt.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(opt.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(opt.tagline, style: const TextStyle(fontSize: 12.5)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                ToolChip(opt.difficulty, color: opt.color),
                ToolChip(opt.cost, color: AppTheme.accentColor),
              ]),
              const SizedBox(height: 6),
              for (var i = 0; i < opt.steps.length; i++)
                _Step(
                    number: i + 1,
                    text: opt.steps[i].$1,
                    code: opt.steps[i].$2),
              if (opt.link != null) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => launchUrl(Uri.parse(opt.link!),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Official documentation'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Connect this app',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const ToolCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Step(
                  number: 1,
                  text:
                      'In n8n open Settings > n8n API and click "Create an API key".'),
              _Step(
                  number: 2,
                  text:
                      'Give it a label, choose an expiry and copy the key (it is shown only once).'),
              _Step(
                  number: 3,
                  text:
                      'In this app tap Settings > Add Instance, paste your server URL and the key.'),
              _Step(
                  number: 4,
                  text:
                      'Test with Server Health. Remote "Run" works through a Webhook trigger on an active workflow.'),
            ],
          ),
        ),
        const ToolCard(
          borderColor: Color(0x55FFB830),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: AppTheme.warningColor),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Security tips: always use HTTPS, keep n8n updated, back up the '
                  'n8n_data volume and set N8N_ENCRYPTION_KEY so credentials can be '
                  'restored on a new server.',
                  style: TextStyle(fontSize: 12.5, height: 1.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String text;
  final String? code;
  const _Step({required this.number, required this.text, this.code});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text('$number',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryColor)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
                if (code != null) CodeBlock(code!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
