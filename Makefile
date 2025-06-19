# Variables
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -Iinclude
SRCDIR = src
TESTDIR = tests
BUILDDIR = build
SOURCES = $(SRCDIR)/main.c $(SRCDIR)/calculator.c
TEST_SOURCES = $(TESTDIR)/test_calculator.c $(SRCDIR)/calculator.c
TARGET = $(BUILDDIR)/calculator
TEST_TARGET = $(BUILDDIR)/test_calculator

# Créer le dossier build s'il n'existe pas
$(BUILDDIR):
	mkdir -p $(BUILDDIR)

# Compilation du programme principal
$(TARGET): $(SOURCES) | $(BUILDDIR)
	$(CC) $(CFLAGS) $(SOURCES) -o $(TARGET)
	@echo "Compilation terminée: $(TARGET)"

# Compilation des tests
$(TEST_TARGET): $(TEST_SOURCES) | $(BUILDDIR)
	$(CC) $(CFLAGS) $(TEST_SOURCES) -o $(TEST_TARGET)
	@echo "Tests compilés: $(TEST_TARGET)"

# Règles principales
.PHONY: all clean test run

all: $(TARGET)

test: $(TEST_TARGET)
	@echo "Exécution des tests..."
	./$(TEST_TARGET)
	@echo "Tests terminés!"

run: $(TARGET)
	@echo "Exécution du programme..."
	./$(TARGET)

clean:
	rm -rf $(BUILDDIR)
	@echo "Nettoyage terminé!"

# Aide
help:
	@echo "Commandes disponibles:"
	@echo "  make all    - Compile le programme"
	@echo "  make test   - Compile et exécute les tests"
	@echo "  make run    - Compile et exécute le programme"
	@echo "  make clean  - Nettoie les fichiers compilés"
