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

Firewalls on Linux normally work on network interfaces, managing and controlling
the networking traffic basing on defined rules. If you want to block any request
of goes on the port 80, for example, a simple configuration could be done. No
*UDP* allowed; no problem at all. However, how to block traffic for only one
application? The Application Firewall shows up.

In a simple summarize, An Application Firewall blocks or limits the application
to receiving or sending traffic to/from a destination. It can have plenty of
utilities, since Servers' applications to Desktops' one, what I was looking for.

I was working on an old game; trying to understand its Network protocol, and how
the binary behavior when something on the connections goes wrong, and something
comes to my mind: "What if I could block the traffic to this server only for
this process?" what brings me to
[*OpenSnitch*](https://github.com/evilsocket/opensnitch).

OpenSnitch (n.d.). *OpenSnitch allows you to create rules for which apps to
allow to access the internet and which to block.* Retrieved from
[It's Foss](https://itsfoss.com/opensnitch-firewall-linux/). Nothing bad to say
about it, but I thought it would be too much for my use case, so I have
continued questing.

Some days after, a light came to my mind: "Should Linux namespaces fit for it?"
I have read about it, but never applied directly, so my theory was: Could I
create a namespace for the application, use *UFW* or *IP Tables* to build my
rules, and have a simpler version of the Application Firewall? The answer is
*Yes*!

The steps to make this test were:

*On the host machine, I created a P2P interfaces...*

```sh
sudo ip link add veth0 type veth peer name veth1
```

*Have configured the IP address...*

```sh
sudo ip addr add 10.0.0.1/24 dev veth0
```

*And started the network interface.*

```sh
sudo ip link set veth0 up
```

*Enable IP forwarding.*

```sh
sudo sysctl -w net.ipv4.ip_forward=1
```

With the interface started, we need to create the namespace, isolating the
network stack, what can be done using the *unshare* command.

```sh
sudo unshare --net /bin/bash
```

*Shows the namespace's PID.*

```sh
echo $$
```

*Sends the interface veth1 to the namespace.*
> This command should be run in the Host environment.

```sh
sudo ip link set veth1 netns <PID> 
```

*Have configured the IP address...*

```sh
sudo ip addr add 10.0.0.2/24 dev veth1
```

*Start the network interface...*

``` sh
sudo ip link set veth1 up
```

*And configure the default route to the host machine.*

```sh
ip route add default via 10.0.0.1
```

To complete the setup, on the host environment too, one extra step is necessary:
allow IP routing to the external interface.

```sh
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o <INTERFACE> -j MASQUERADE
```

After this configuration process, the *bash* initialized with *unshare* could be
used to set *UWF* rules, for example, to block the desirable traffic,
essentially blocking only the application/applications that runs inside this
bash instance.

It's a straightforward approach, but it works! Thanks for reading, and I hope
this helps.
