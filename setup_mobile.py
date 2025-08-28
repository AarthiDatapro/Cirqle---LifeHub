#!/usr/bin/env python3
"""
LifeHub Mobile Setup Script
This script helps configure the app for mobile development by finding your IP address
and updating the configuration files.
"""

import socket
import subprocess
import platform
import os
import re

def get_local_ip():
    """Get the local IP address of the machine."""
    try:
        # Connect to a remote address to get local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        return "127.0.0.1"

def get_network_info():
    """Get network information based on the operating system."""
    system = platform.system()
    
    if system == "Windows":
        try:
            result = subprocess.run(['ipconfig'], capture_output=True, text=True)
            lines = result.stdout.split('\n')
            for line in lines:
                if 'IPv4 Address' in line and '192.168.' in line:
                    ip = re.search(r'(\d+\.\d+\.\d+\.\d+)', line)
                    if ip:
                        return ip.group(1)
        except:
            pass
    elif system in ["Darwin", "Linux"]:  # macOS or Linux
        try:
            result = subprocess.run(['ifconfig'], capture_output=True, text=True)
            lines = result.stdout.split('\n')
            for line in lines:
                if 'inet ' in line and '192.168.' in line:
                    ip = re.search(r'inet (\d+\.\d+\.\d+\.\d+)', line)
                    if ip:
                        return ip.group(1)
        except:
            pass
    
    return get_local_ip()

def update_api_config(ip_address):
    """Update the API configuration file with the IP address."""
    config_file = "frontend/lib/config/api_config.dart"
    
    if not os.path.exists(config_file):
        print(f"❌ Configuration file not found: {config_file}")
        return False
    
    try:
        with open(config_file, 'r') as f:
            content = f.read()
        
        # Update the mobile development URL
        updated_content = re.sub(
            r"static const String mobileDevBaseUrl = 'http://[^']+';",
            f"static const String mobileDevBaseUrl = 'http://{ip_address}:4000/api';",
            content
        )
        
        updated_content = re.sub(
            r"static const String mobileDevServerUrl = 'http://[^']+';",
            f"static const String mobileDevServerUrl = 'http://{ip_address}:4000';",
            updated_content
        )
        
        with open(config_file, 'w') as f:
            f.write(updated_content)
        
        print(f"✅ Updated API configuration with IP: {ip_address}")
        return True
    except Exception as e:
        print(f"❌ Error updating configuration: {e}")
        return False

def test_connection(ip_address):
    """Test if the server is accessible from the given IP."""
    import urllib.request
    import urllib.error
    
    try:
        url = f"http://{ip_address}:4000"
        urllib.request.urlopen(url, timeout=5)
        print(f"✅ Server is accessible at: {url}")
        return True
    except urllib.error.URLError:
        print(f"❌ Server is not accessible at: {url}")
        print("   Make sure the server is running and port 4000 is open")
        return False
    except Exception as e:
        print(f"❌ Connection test failed: {e}")
        return False

def main():
    print("🚀 LifeHub Mobile Setup")
    print("=" * 40)
    
    # Get IP address
    print("🔍 Finding your IP address...")
    ip_address = get_network_info()
    print(f"📍 Your IP address: {ip_address}")
    
    # Update configuration
    print("\n📝 Updating API configuration...")
    if update_api_config(ip_address):
        print("✅ Configuration updated successfully!")
    else:
        print("❌ Failed to update configuration")
        return
    
    # Test connection
    print("\n🔗 Testing server connection...")
    if test_connection(ip_address):
        print("\n🎉 Setup completed successfully!")
        print("\n📱 To run on mobile:")
        print("   1. Make sure your mobile device is on the same network")
        print("   2. Run: flutter run --dart-define=ENVIRONMENT=mobile")
        print("   3. Or run: flutter run -d android --dart-define=ENVIRONMENT=mobile")
    else:
        print("\n⚠️  Setup completed but server connection failed.")
        print("   Please check:")
        print("   - Server is running (npm run dev in server directory)")
        print("   - Firewall allows connections on port 4000")
        print("   - Mobile device is on the same network")

if __name__ == "__main__":
    main()
