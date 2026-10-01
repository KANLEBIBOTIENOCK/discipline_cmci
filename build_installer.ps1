$releaseDir = "c:\Users\HP\Desktop\Discipline\build\windows\x64\runner\Release"
$zipPath = "$env:TEMP\aline_payload.zip"
$iconPath = "c:\Users\HP\Desktop\Discipline\windows\runner\resources\app_icon.ico"
$outputInstaller = "C:\Users\HP\Desktop\Aline_Setup.exe"

# Create ZIP archive of release folder
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Write-Host "Création de l'archive de l'application Aline..."
Compress-Archive -Path "$releaseDir\*" -DestinationPath $zipPath -CompressionLevel Optimal

# Write C# installer code
$csCode = @'
using System;
using System.IO;
using System.IO.Compression;
using System.Drawing;
using System.Windows.Forms;
using System.Threading;
using System.Diagnostics;
using System.Reflection;

namespace AlineInstaller
{
    public class InstallerForm : Form
    {
        private ProgressBar progressBar;
        private Label statusLabel;
        private Label titleLabel;
        private Label subtitleLabel;
        private Button installButton;
        private CheckBox launchCheckBox;
        private bool isFinished = false;

        public InstallerForm()
        {
            this.Text = "Installation - Aline";
            this.Size = new Size(520, 380);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.BackColor = Color.FromArgb(253, 248, 249);

            try
            {
                using (var iconStream = Assembly.GetExecutingAssembly().GetManifestResourceStream("app_icon.ico"))
                {
                    if (iconStream != null)
                    {
                        this.Icon = new Icon(iconStream);
                    }
                }
            }
            catch {}

            // Header Banner
            Panel headerPanel = new Panel();
            headerPanel.Size = new Size(520, 90);
            headerPanel.BackColor = Color.FromArgb(233, 30, 99);
            headerPanel.Dock = DockStyle.Top;
            this.Controls.Add(headerPanel);

            titleLabel = new Label();
            titleLabel.Text = "Aline 🌸";
            titleLabel.Font = new Font("Segoe UI", 16, FontStyle.Bold);
            titleLabel.ForeColor = Color.White;
            titleLabel.Location = new Point(20, 16);
            titleLabel.AutoSize = true;
            headerPanel.Controls.Add(titleLabel);

            subtitleLabel = new Label();
            subtitleLabel.Text = "Suivi des disciplines spirituelles - Version Windows";
            subtitleLabel.Font = new Font("Segoe UI", 9.5f, FontStyle.Regular);
            subtitleLabel.ForeColor = Color.FromArgb(255, 230, 240);
            subtitleLabel.Location = new Point(22, 52);
            subtitleLabel.AutoSize = true;
            headerPanel.Controls.Add(subtitleLabel);

            // Content
            Label descLabel = new Label();
            descLabel.Text = "Bienvenue dans l'assistant d'installation d'Aline.\nCliquez sur « Installer » pour installer automatiquement l'application sur votre PC.";
            descLabel.Font = new Font("Segoe UI", 9.5f);
            descLabel.Location = new Point(25, 110);
            descLabel.Size = new Size(460, 45);
            this.Controls.Add(descLabel);

            statusLabel = new Label();
            statusLabel.Text = "Prêt pour l'installation.";
            statusLabel.Font = new Font("Segoe UI", 9, FontStyle.Italic);
            statusLabel.ForeColor = Color.FromArgb(80, 80, 80);
            statusLabel.Location = new Point(25, 175);
            statusLabel.Size = new Size(460, 25);
            this.Controls.Add(statusLabel);

            progressBar = new ProgressBar();
            progressBar.Location = new Point(25, 205);
            progressBar.Size = new Size(460, 26);
            progressBar.Style = ProgressBarStyle.Blocks;
            this.Controls.Add(progressBar);

            launchCheckBox = new CheckBox();
            launchCheckBox.Text = "Lancer Aline après l'installation";
            launchCheckBox.Font = new Font("Segoe UI", 9.5f);
            launchCheckBox.Location = new Point(25, 245);
            launchCheckBox.Size = new Size(400, 25);
            launchCheckBox.Checked = true;
            this.Controls.Add(launchCheckBox);

            // Bottom Buttons
            installButton = new Button();
            installButton.Text = "Installer";
            installButton.Font = new Font("Segoe UI", 10, FontStyle.Bold);
            installButton.BackColor = Color.FromArgb(233, 30, 99);
            installButton.ForeColor = Color.White;
            installButton.FlatStyle = FlatStyle.Flat;
            installButton.FlatAppearance.BorderSize = 0;
            installButton.Size = new Size(120, 36);
            installButton.Location = new Point(365, 285);
            installButton.Click += InstallButton_Click;
            this.Controls.Add(installButton);
        }

        private void InstallButton_Click(object sender, EventArgs e)
        {
            if (isFinished)
            {
                if (launchCheckBox.Checked)
                {
                    string installDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Aline");
                    string exePath = Path.Combine(installDir, "discipline_cmci.exe");
                    if (File.Exists(exePath))
                    {
                        Process.Start(new ProcessStartInfo(exePath) { WorkingDirectory = installDir });
                    }
                }
                Application.Exit();
                return;
            }

            installButton.Enabled = false;
            progressBar.Value = 15;
            statusLabel.Text = "Préparation des fichiers...";

            Thread worker = new Thread(DoInstallation);
            worker.IsBackground = true;
            worker.Start();
        }

        private void DoInstallation()
        {
            try
            {
                string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                string installDir = Path.Combine(localAppData, "Aline");

                if (!Directory.Exists(installDir))
                {
                    Directory.CreateDirectory(installDir);
                }

                this.Invoke((MethodInvoker)delegate {
                    progressBar.Value = 35;
                    statusLabel.Text = "Extraction des composants...";
                });

                string tempZip = Path.Combine(Path.GetTempPath(), "aline_temp_install.zip");
                using (Stream resStream = Assembly.GetExecutingAssembly().GetManifestResourceStream("payload.zip"))
                {
                    using (FileStream fs = new FileStream(tempZip, FileMode.Create))
                    {
                        resStream.CopyTo(fs);
                    }
                }

                // Extract ZIP overwriting
                using (ZipArchive archive = ZipFile.OpenRead(tempZip))
                {
                    int count = 0;
                    int total = archive.Entries.Count;
                    foreach (ZipArchiveEntry entry in archive.Entries)
                    {
                        string destinationPath = Path.GetFullPath(Path.Combine(installDir, entry.FullName));
                        if (string.IsNullOrEmpty(entry.Name))
                        {
                            Directory.CreateDirectory(destinationPath);
                        }
                        else
                        {
                            Directory.CreateDirectory(Path.GetDirectoryName(destinationPath));
                            entry.ExtractToFile(destinationPath, true);
                        }
                        count++;
                        int progressVal = 35 + (int)((count / (float)total) * 45);
                        this.Invoke((MethodInvoker)delegate {
                            if (progressVal <= 80) progressBar.Value = progressVal;
                        });
                    }
                }
                try { File.Delete(tempZip); } catch {}

                this.Invoke((MethodInvoker)delegate {
                    progressBar.Value = 85;
                    statusLabel.Text = "Création des raccourcis Bureau et Menu Démarrer...";
                });

                // Create Desktop Shortcut
                string desktopDir = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
                string exePath = Path.Combine(installDir, "discipline_cmci.exe");
                CreateShortcut(Path.Combine(desktopDir, "Aline.lnk"), exePath, installDir);

                // Create Start Menu Shortcut
                string startMenuDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.StartMenu), "Programs");
                CreateShortcut(Path.Combine(startMenuDir, "Aline.lnk"), exePath, installDir);

                Thread.Sleep(300);

                this.Invoke((MethodInvoker)delegate {
                    progressBar.Value = 100;
                    statusLabel.Text = "Installation terminée avec succès !";
                    statusLabel.ForeColor = Color.DarkGreen;
                    installButton.Text = "Terminer";
                    installButton.Enabled = true;
                    isFinished = true;
                });
            }
            catch (Exception ex)
            {
                this.Invoke((MethodInvoker)delegate {
                    statusLabel.Text = "Erreur : " + ex.Message;
                    statusLabel.ForeColor = Color.Red;
                    installButton.Enabled = true;
                });
            }
        }

        private void CreateShortcut(string shortcutPath, string targetPath, string workingDir)
        {
            try
            {
                Type shellType = Type.GetTypeFromProgID("WScript.Shell");
                dynamic shell = Activator.CreateInstance(shellType);
                var shortcut = shell.CreateShortcut(shortcutPath);
                shortcut.TargetPath = targetPath;
                shortcut.WorkingDirectory = workingDir;
                shortcut.Description = "Aline - Suivi des disciplines spirituelles";
                shortcut.Save();
            }
            catch {}
        }

        [STAThread]
        public static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new InstallerForm());
        }
    }
}
'@

$csFile = "$env:TEMP\AlineInstaller.cs"
[System.IO.File]::WriteAllText($csFile, $csCode)

Write-Host "Compilation de l'installeur Aline_Setup.exe..."
$csc = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
$compileArgs = @(
    "/target:winexe",
    "/out:$outputInstaller",
    "/win32icon:$iconPath",
    "/resource:$zipPath,payload.zip",
    "/resource:$iconPath,app_icon.ico",
    "/reference:System.dll",
    "/reference:System.Windows.Forms.dll",
    "/reference:System.Drawing.dll",
    "/reference:System.IO.Compression.dll",
    "/reference:System.IO.Compression.FileSystem.dll",
    "/reference:Microsoft.CSharp.dll",
    "/optimize+",
    $csFile
)

Start-Process -FilePath $csc -ArgumentList $compileArgs -NoNewWindow -Wait

if (Test-Path $outputInstaller) {
    Write-Host "SUCCESS: Installeur généré à $outputInstaller"
    Copy-Item $outputInstaller "c:\Users\HP\Desktop\Discipline\Aline_Setup.exe" -Force
} else {
    Write-Host "Échec de la compilation."
}
