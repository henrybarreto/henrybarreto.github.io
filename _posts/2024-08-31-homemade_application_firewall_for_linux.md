---
layout: post
title: Homemade application firewall for Linux 
description:
    Utilize Linux namespaces alongside tools like UFW or IP Tables to create an
    isolated network environment tailored for specific applications. This approach
    allows for precise control over application traffic, offering a simple and easy
    solution for managing network access and implementing firewall rules on Linux.
keywords: linux, application, firewall, ip, namespaces, simple, easy
---

### Application-Specific Firewall on Linux Using Namespaces

Firewalls on Linux typically operate at the network interface level, managing
and controlling network traffic based on predefined rules. For example, blocking
all requests on port 80 is a straightforward configuration. However, what if you
need to block traffic for a single application rather than an entire network
interface? This is where an **Application Firewall** comes into play.

### What is an Application Firewall?

An **Application Firewall** allows you to block or restrict specific
applications from sending or receiving network traffic. This can be useful in
various scenarios, from securing server applications to controlling desktop
software.

I recently needed such a solution while working on an old game,
analyzing its network protocol and how it behaves under different connection
conditions. A question came to mind:

> *"What if I could block traffic to this server for just this process?"*

This led me to discover
[**OpenSnitch**](https://github.com/evilsocket/opensnitch), a Linux application
firewall that allows per-application network rules. While OpenSnitch is great, I
found it too complex for my specific needs. So, I continued my search for a more
lightweight approach.

### Using Linux Namespaces for Application-Specific Firewalling

A few days later, I had an idea: *Could Linux namespaces help achieve this?*
Since Linux namespaces allow process isolation, I theorized that by creating a
dedicated network namespace and applying **UFW** or **iptables** rules within
it, I could effectively build a minimalistic Application Firewall. The answer?
*Yes!*

#### Steps to Set Up an Application-Specific Firewall Using Network Namespaces

Here’s how I set up a simple firewall for an application using network namespaces:

1. **Create a virtual Ethernet pair (veth interfaces) on the host machine:**
```sh
sudo ip link add veth0 type veth peer name veth1
```

2. **Assign an IP address to one end of the veth pair (host side):**
```sh
sudo ip addr add 10.0.0.1/24 dev veth0
```

3. **Bring up the host-side interface:**
```sh
sudo ip link set veth0 up
```

4. **Enable IP forwarding on the host:**
```sh
sudo sysctl -w net.ipv4.ip_forward=1
```

5. **Create a new network namespace and enter it:**
```sh
sudo unshare --net /bin/bash
```

6. **Retrieve the namespace’s process ID (PID):**
```sh
echo $$
```

7. **Move the second veth interface (veth1) into the new namespace (run this from the host):**
```sh
sudo ip link set veth1 netns <PID>
```

8. **Inside the namespace, assign an IP to veth1:**
```sh
sudo ip addr add 10.0.0.2/24 dev veth1
```

9. **Bring up the interface inside the namespace:**
```sh
sudo ip link set veth1 up
```

10. **Set up a default route to the host machine inside the namespace:**
```sh
ip route add default via 10.0.0.1
```

11. **On the host, enable NAT for outbound traffic:**
```sh
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o <INTERFACE> -j MASQUERADE
```

#### Applying Firewall Rules

Now that the isolated namespace is set up, you can apply firewall rules to
control traffic for applications running within it. For example, using **UFW**
inside the namespace’s shell, you could block outgoing traffic to a specific
address or port:

```sh
sudo ufw deny out to 192.168.1.100 port 80
```

### Conclusion

This approach provides a lightweight, flexible way to restrict network access at
the application level without using full-fledged application firewalls like
OpenSnitch. By leveraging **Linux namespaces** and **iptables**, you gain
fine-grained control over networking per process, making it an excellent
solution for debugging, security, and research.

Thanks for reading, and I hope this helps!
