# Verification record

Engine: Godot 4.4.1 stable, Linux x86_64, Compatibility renderer.

## Engine-driven gameplay checks — 30 passed

1. Player rests on a solid floor.
2. WASD input moves the player.
3. Mouse-look input rotates the camera.
4. Red door refuses entry without the key.
5. Locked gate blocks enemy navigation.
6. Normal door slides open and disables collision.
7. Red-key route is reachable through the navigation grid.
8. Firing consumes one round.
9. A physics hitscan damages a drone for 25 HP.
10. A second shot kills the 50 HP drone.
11. Death increments the kill count.
12. A partial reload conserves ammunition.
13. An empty weapon cannot create rounds.
14. Health collection clamps at 100 HP.
15. Ammo collection adds 24 spare rounds.
16. Key collection grants red clearance.
17. Red clearance opens the locked door.
18. Final-room route becomes reachable after unlocking.
19. Secret discovery is recorded.
20. An enemy chases and approaches the player.
21. A mouse attack reduces player health.
22. A mouse dies from one blaster hit.
23. The elevator remains sealed before final clearance.
24. Final room spawns three drones and five mice.
25. Killing the final guards opens the elevator.
26. Pause freezes the scene tree.
27. Resume restores processing.
28. Lethal damage opens the death/restart screen.
29. Reset restores initial health, ammunition, and key state.
30. Entering the cleared elevator completes the level.

## Additional checks

- Full scene reload after death recreates the player and 15 initial enemies and clears pause state.
- Godot editor import and launch succeeded without GDScript parse errors.
- A real OpenGL software-rendered launch succeeded; `PREVIEW.png` was captured from the game and visually inspected for the environment, enemies, gun/paws, crosshair, and HUD.
- Launch succeeds without external textures, models, voice recordings, or WAV files; placeholders are generated at runtime.
- The graphical capture finished without game errors. Headless Dummy-audio checks printed a non-fatal AudioStream playback cleanup warning at shutdown. No gameplay assertions failed.

## Limits

The checks automate specific gameplay states, including teleporting to test locations. They are not a human continuous playthrough. Level pacing (target 5–10 minutes), subjective combat balance, hardware audio playback, Mac/Windows exports, and physical touchscreen usability still need hands-on evaluation. The delivered file is a Godot source project, not an exported application.
