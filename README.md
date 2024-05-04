# Evented fault simulator

## TL;DR

```sh
make
make install

make demo

make clean
```

## Evented simulator

Imagine a system where you have

```mermaid
flowchart LR
    A["🧑‍💻 Frontend"] -->|GraphQL| B1("💾 Backend 1")
    A -->|GraphQL| B1
    A -->|"1️⃣ GraphQL ❌/✅"| B1
    A -->|GraphQL| B1
    B1 <--> IOB("📬 In/Outbox")
    IOB -->|message| EB("🚐 Event Bus")
    IOB -->|"2️⃣ message ❌/✅"| EB
    EB -->|message| L1("ƛ lambda")
    EB -->|"7️⃣ message ❌/✅"| L1
    EB -->|message| L1
    L1 -->|message| IOB
    L1 -->|"8️⃣ message ❌/✅"| IOB
    EB -->|message| L2("ƛ lambda")
    EB -->|message| L2
    EB -->|"3️⃣ message ❌/✅"| L2
    L2 -->|message| IOB2("📬 In/Outbox")
    L2 -->|"4️⃣ message ❌/✅"| IOB2
    IOB2 --> B2("💾 Backend 2")
    IOB2 -->|message| EB
    IOB2 -->|"6️⃣ message ❌/✅"| EB
    B2 -->|processing| B2
    B2 -->|"5️⃣ processing ❌/✅"| B2
    B2 --> IOB2("📬 Outbox 2")
```

1. **Frontend** can fail to communicate to the **backend**
2. **Backend** outbox can fail to publish to the **event bus**
3. **Event bus** message may fail to be read by a **lambda**
4. **Lambda** may fail to write to the **Inbox** of anouther **backend** Inbox
5. **processing** could fail on the microservice
6. **Outbox** of microservice may fail to publis to the **event bus**
7. **Event bus** message may fail to be read by a **lambda**
8. **Lambda** may fail to write to the **Inbox**

The idea is to have simple telemetry system that takes telemetry data from each
"service" and is displayed in a frontend visulaisation system.

